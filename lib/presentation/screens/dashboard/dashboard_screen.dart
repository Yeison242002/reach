import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> historial = [
      {
        'salida': 'C',
        'accion': 'Se apagó',
        'fecha': '13/05/2025',
        'hora': '8:00 Pm',
        'user': 'yeison',
      },
      {
        'salida': 'B',
        'accion': 'Se desconectó',
        'fecha': '3/05/2025',
        'hora': '7:00 Pm',
        'user': 'yeison',
      },
      {
        'salida': 'A',
        'accion': 'Se encendió',
        'fecha': '11/05/2025',
        'hora': '8:00 Am',
        'user': 'manuel',
      },
    ];

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
              // Navegar a perfil si quieres
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
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: const Text(
    'Ver historial de consumo',
    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
  ),
),

            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
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
                            'SALIDA (${item['salida']})   ${item['accion']}',
                            style: TextStyle(
                              color: item['accion']!.contains('encendió')
                                  ? Colors.purple
                                  : Colors.pinkAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item['fecha']}:  ${item['hora']}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            'User: ${item['user']}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
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

