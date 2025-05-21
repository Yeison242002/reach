import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

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
                  fontSize: 20),
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
          )
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
            Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Watts consumidos\ndía promedio:',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '300.07w',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '30.000\$',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Promedio diario individual',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('SALIDA (A):', style: TextStyle(color: Colors.white)),
                Text('100.00watts',
                    style: TextStyle(color: Colors.purpleAccent)),
                Text('10.000\$',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('SALIDA (B):', style: TextStyle(color: Colors.white)),
                Text('50.00watts',
                    style: TextStyle(color: Colors.purpleAccent)),
                Text('5.000\$',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('SALIDA (C):', style: TextStyle(color: Colors.white)),
                Text('150.00watts',
                    style: TextStyle(color: Colors.purpleAccent)),
                Text('15.000\$',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Se estima que al final\ndel mes se consuman:',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '3,000.07w',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '300.000\$',
                    style: TextStyle(color: Colors.white),
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
