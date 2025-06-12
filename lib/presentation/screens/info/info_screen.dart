import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  double totalWattsDia = 0;
  double costoDia = 0;
  double wattsA = 0;
  double wattsB = 0;
  double wattsC = 0;
  double costoA = 0;
  double costoB = 0;
  double costoC = 0;
  double estimadoMesWatts = 0;
  double estimadoMesCOP = 0;

  double costoKWh = 1228;
  bool editingCosto = false;
  final TextEditingController costoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarCostoKWh().then((_) => calcularEstadisticas());
  }

  Future<void> cargarCostoKWh() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('config')
            .doc('costo_kwh')
            .get();
    if (doc.exists) {
      setState(() {
        costoKWh = (doc.data()?['valor'] ?? 1228).toDouble();
      });
    }
  }

  Future<void> guardarCostoKWh(double nuevoValor) async {
    await FirebaseFirestore.instance.collection('config').doc('costo_kwh').set({
      'valor': nuevoValor,
    });
    setState(() {
      costoKWh = nuevoValor;
      editingCosto = false;
    });
    calcularEstadisticas();
  }

  Future<void> calcularEstadisticas() async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    final fechaActual = DateFormat('yyyy-MM-dd').format(now);
    final mesActual = DateFormat('yyyy-MM').format(now);

    final snap =
        await firestore
            .collection('consumo_diario')
            .doc(fechaActual)
            .collection('HistorialConsumo')
            .get();
    if (snap.docs.isEmpty) return;

    double totalDia = 0;
    double sumA = 0;
    double sumB = 0;
    double sumC = 0;
    int count = 0;

    for (var doc in snap.docs) {
      final data = doc.data();
      totalDia += (data['total_watts'] ?? 0).toDouble();
      sumA += (data['watts_a'] ?? 0).toDouble();
      sumB += (data['watts_b'] ?? 0).toDouble();
      sumC += (data['watts_c'] ?? 0).toDouble();
      count++;
    }

    final promedioDia = totalDia / count;
    final promedioA = sumA / count;
    final promedioB = sumB / count;
    final promedioC = sumC / count;

    final costoDiaTotal = (promedioDia / 1000) * costoKWh;
    final costoSalidaA = (promedioA / 1000) * costoKWh;
    final costoSalidaB = (promedioB / 1000) * costoKWh;
    final costoSalidaC = (promedioC / 1000) * costoKWh;

    final snapMes = await firestore.collection('consumo_diario').get();
    double sumaMes = 0;
    int diasConDatos = 0;

    for (var doc in snapMes.docs) {
      if (doc.id.startsWith(mesActual)) {
        final sub = await doc.reference.collection('HistorialConsumo').get();
        for (var h in sub.docs) {
          sumaMes += (h.data()['total_watts'] ?? 0).toDouble();
          diasConDatos++;
        }
      }
    }

    final diasDelMes = DateTime(now.year, now.month + 1, 0).day;
    final promedioDiaMes = diasConDatos > 0 ? (sumaMes / diasConDatos) : 0;
    final diasFaltantes = diasDelMes - now.day;
    final estimadoFinal = promedioDiaMes * diasFaltantes;
    final estimadoFinalCOP = (estimadoFinal / 1000) * costoKWh;

    setState(() {
      totalWattsDia = promedioDia;
      costoDia = costoDiaTotal;
      wattsA = promedioA;
      wattsB = promedioB;
      wattsC = promedioC;
      costoA = costoSalidaA;
      costoB = costoSalidaB;
      costoC = costoSalidaC;
      estimadoMesWatts = estimadoFinal.toDouble();
      estimadoMesCOP = estimadoFinalCOP.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Text(
              'Estadísticas ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            Icon(Icons.info, color: Colors.purpleAccent),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Estadísticas de consumo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child:
                      editingCosto
                          ? TextField(
                            controller:
                                costoController
                                  ..text = costoKWh.toStringAsFixed(0),
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Costo kWh (COP)',
                              labelStyle: TextStyle(color: Colors.white54),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.purpleAccent,
                                ),
                              ),
                            ),
                            onSubmitted: (value) {
                              final nuevoCosto = double.tryParse(value);
                              if (nuevoCosto != null) {
                                guardarCostoKWh(nuevoCosto);
                              }
                            },
                          )
                          : Text(
                            'Costo kWh: ${costoKWh.toStringAsFixed(0)} \$',
                            style: const TextStyle(color: Colors.white),
                          ),
                ),
                IconButton(
                  icon: Icon(
                    editingCosto ? Icons.check : Icons.edit,
                    color: Colors.purpleAccent,
                  ),
                  onPressed: () {
                    if (editingCosto) {
                      final nuevoCosto = double.tryParse(costoController.text);
                      if (nuevoCosto != null) {
                        guardarCostoKWh(nuevoCosto);
                      }
                    } else {
                      setState(() {
                        editingCosto = true;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Promedio día total de hoy:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${totalWattsDia.toStringAsFixed(2)} watts',
              style: TextStyle(color: Colors.purpleAccent, fontSize: 20),
            ),
            Text(
              'Costo estimado hoy: \$${costoDia.toStringAsFixed(2)} COP',
              style: TextStyle(color: Colors.greenAccent, fontSize: 16),
            ),
            const SizedBox(height: 20),

            const Text(
              'Promedio diario individual',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SALIDA (A):',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  '${wattsA.toStringAsFixed(2)}w',
                  style: const TextStyle(color: Colors.purpleAccent),
                ),
                Text(
                  '${costoA.toStringAsFixed(0)} \$',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SALIDA (B):',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  '${wattsB.toStringAsFixed(2)}w',
                  style: const TextStyle(color: Colors.purpleAccent),
                ),
                Text(
                  '${costoB.toStringAsFixed(0)} \$',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SALIDA (C):',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  '${wattsC.toStringAsFixed(2)}w',
                  style: const TextStyle(color: Colors.purpleAccent),
                ),
                Text(
                  '${costoC.toStringAsFixed(0)} \$',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Se estima que al final\ndel mes se consuman:',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${estimadoMesWatts.toStringAsFixed(2)}w',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${estimadoMesCOP.toStringAsFixed(0)} \$',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
