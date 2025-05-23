import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TimerModel {
  final String salida;
  final String accion;
  final String fecha;
  final String hora;
  final String? usuario;

  TimerModel({
    required this.salida,
    required this.accion,
    required this.fecha,
    required this.hora,
    this.usuario,
  });

  Map<String, dynamic> toMap() {
    return {
      'salida': salida,
      'accion': accion,
      'fecha': fecha,
      'hora': hora,
      'usuario': usuario,
    };
  }

  factory TimerModel.fromMap(Map<String, dynamic> map) {
    return TimerModel(
      salida: map['salida'],
      accion: map['accion'],
      fecha: map['fecha'],
      hora: map['hora'],
      usuario: map['usuario'],
    );
  }
}

Future<void> guardarProgramacion(TimerModel timer, BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  final nombreUsuario = userDoc.data()?['name'] ?? 'Desconocido';

  final data = timer.toMap();
  data['usuario'] = nombreUsuario;

  await FirebaseFirestore.instance.collection('timers').add(data);
}

Future<void> mostrarDialogoAgregarTimer(BuildContext context) async {
  String salida = 'A';
  String accion = 'Encender';
  DateTime fechaHora = DateTime.now();

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF2E2645),
        title: const Text('Añadir programación', style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: salida,
                  decoration: const InputDecoration(labelText: 'Salida'),
                  dropdownColor: Colors.deepPurple,
                  style: const TextStyle(color: Colors.white),
                  items: ['A', 'B', 'C']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) => setState(() => salida = value!),
                ),
                DropdownButtonFormField<String>(
                  value: accion,
                  decoration: const InputDecoration(labelText: 'Acción'),
                  dropdownColor: Colors.deepPurple,
                  style: const TextStyle(color: Colors.white),
                  items: ['Encender', 'Apagar']
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (value) => setState(() => accion = value!),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: fechaHora,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          fechaHora = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                  child: const Text('Seleccionar fecha y hora'),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final fechaFormateada =
                  '${fechaHora.day.toString().padLeft(2, '0')}/${fechaHora.month.toString().padLeft(2, '0')}/${fechaHora.year}';
              final horaFormateada =
                  '${fechaHora.hour % 12 == 0 ? 12 : fechaHora.hour % 12}:${fechaHora.minute.toString().padLeft(2, '0')} ${fechaHora.hour >= 12 ? 'Pm' : 'Am'}';

              final nuevoTimer = TimerModel(
                salida: salida,
                accion: accion,
                fecha: fechaFormateada,
                hora: horaFormateada,
              );
              await guardarProgramacion(nuevoTimer, context);
              Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );
}

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1B2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Programación',
          style: TextStyle(color: Colors.white),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Programación de encendido y apagado',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('timers').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data!.docs.map((doc) {
                    final t = doc.data() as Map<String, dynamic>;
                    return TimerModel.fromMap(t);
                  }).toList();

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      return Card(
                        color: const Color(0xFF3A2F54),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            'SALIDA (${item.salida})',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.accion,
                                style: TextStyle(
                                  color: item.accion == 'Encender'
                                      ? Colors.purple
                                      : Colors.pinkAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${item.fecha}: ${item.hora}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              if (item.usuario != null)
                                Text(
                                  'Programado por: ${item.usuario}',
                                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.purple.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('timers')
                                  .doc(snapshot.data!.docs[index].id)
                                  .delete();
                            },
                            child: const Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, size: 36),
        onPressed: () {
          mostrarDialogoAgregarTimer(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
