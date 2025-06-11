import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reach/data/models/historial_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String firestoreURL =
      'https://firestore.googleapis.com/v1/projects/reach-55adb/databases/(default)/documents/historial';

  Future<List<HistorialModel>> fetchHistorial() async {
    final response = await http.get(Uri.parse(firestoreURL));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final docs = data['documents'] as List<dynamic>;
      return docs.map((doc) {
        final fields = doc['fields'];
        return HistorialModel.fromFirestore(fields);
      }).toList();
    } else {
      throw Exception('Error al cargar historial');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1B2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.article_outlined, color: Colors.purple),
            SizedBox(width: 8),
            Text('Historial', style: TextStyle(color: Colors.white)),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historial de monitoreo',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/consumption-history');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade100,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ver historial de consumo',
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<HistorialModel>>(
                future: fetchHistorial(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No hay historial disponible',
                        style: TextStyle(color: Colors.white70));
                  }

                  final historial = snapshot.data!;
                  return ListView.builder(
                    itemCount: historial.length,
                    itemBuilder: (context, index) {
                      final item = historial[index];
                      return Card(
                        color: const Color(0xFF3A2F54),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SALIDA (${item.salida})   ${item.accion}',
                                style: TextStyle(
                                  color: item.accion.contains('encendió')
                                      ? Colors.purple
                                      : Colors.pinkAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.fecha}:  ${item.hora}',
                                style:
                                    const TextStyle(color: Colors.white),
                              ),
                              Text(
                                'User: ${item.usuario}',
                                style:
                                    const TextStyle(color: Colors.white70),
                              ),
                            ],
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
    );
  }
}
