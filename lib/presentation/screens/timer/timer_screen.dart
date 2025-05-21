import 'package:flutter/material.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> timers = [
      {
        'salida': 'A',
        'accion': 'Encender',
        'fecha': '16/08/2025',
        'hora': '8:00 Am',
      },
      {
        'salida': 'B',
        'accion': 'Apagar',
        'fecha': '16/05/2025',
        'hora': '9:30 Am',
      },
      {
        'salida': 'A',
        'accion': 'Encender',
        'fecha': '18/04/2025',
        'hora': '6:00 Pm',
      },
      {
        'salida': 'C',
        'accion': 'Apagar',
        'fecha': '13/05/2025',
        'hora': '8:00 Pm',
      },
    ];

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
            onPressed: () {Navigator.pushNamed(context, '/profile');},
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
              child: ListView.builder(
                itemCount: timers.length,
                itemBuilder: (context, index) {
                  final item = timers[index];
                  return Card(
                    color: const Color(0xFF3A2F54),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        'SALIDA (${item['salida']})',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['accion'],
                            style: TextStyle(
                              color: item['accion'] == 'Encender' ? Colors.purple : Colors.pinkAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${item['fecha']}: ${item['hora']}',
                            style: const TextStyle(color: Colors.white70),
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
                        onPressed: () {},
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
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
          // Lógica para agregar nueva programación
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
