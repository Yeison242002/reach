import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1B2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              // Navegar a perfil si quieres
              // Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monitoreo general',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.power_settings_new, color: Colors.purple),
                  onPressed: () {},
                )
              ],
            ),
            SizedBox(
              width: 190,
              height: 190,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 150,
                    ranges: <GaugeRange>[
                      GaugeRange(startValue: 0, endValue: 50, color: Colors.green),
                      GaugeRange(startValue: 50, endValue: 100, color: Colors.yellow),
                      GaugeRange(startValue: 100, endValue: 150, color: Colors.red),
                    ],
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: 156.09,
                        needleColor: Colors.white, // Color de la aguja
                        needleStartWidth: 0.5,       // Ancho inicial de la aguja
                        needleEndWidth: 3,         // Ancho final de la aguja
                        needleLength: 0.8,         // Longitud de la aguja (0 a 1)
                      knobStyle: KnobStyle(
                        knobRadius: 0.01,        // Radio del knob (círculo central)
                        color: const Color.fromARGB(255, 121, 67, 108),     // Color del knob
                        borderColor: Colors.white, // Borde del knob
                        borderWidth: 0.1,          // Ancho del borde del knob
                      ),
                      tailStyle: TailStyle(
                        color: Colors.white,     // Color de la cola de la aguja
                        length: 0.2,             // Longitud de la cola (0 a 1)
                        width: 3,                // Ancho de la cola
                    ),
                    ),
                      
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Text(
                          '78.09\nwatts',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        angle: 90,
                        positionFactor: 0.8,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _circularGauge('vol', 130.4),
                _circularGauge('A', 4.67),
              ],
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Monitoreo por salidas',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _outputTile('SALIDA (${String.fromCharCode(65 + index)})');
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _circularGauge(String label, double value) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF3A2F54),
          ),
          alignment: Alignment.center,
          child: Text(
            '$label\n$value',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }

  Widget _outputTile(String title) {
    return Card(
      color: const Color(0xFF3A2F54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: const Text(
          'Watts: 45.8    Vol: 130.4    A: 3.8',
          style: TextStyle(color: Colors.purple),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.power_settings_new, color: Colors.purple),
          onPressed: () {},
        ),
      ),
    );
  }
}
