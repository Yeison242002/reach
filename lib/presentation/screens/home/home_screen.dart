import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../../services/mqtt_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late MQTTService _mqttService;
  final Map<String, bool> relayStates = {
    'A': false,
    'B': false,
    'C': false,
  };
  double voltage = 0.0;

  @override
void initState() {
  super.initState();
  _mqttService = MQTTService();
  _mqttService.connect().then((_) {
    _mqttService.subscribeToVoltage((double v) {
      setState(() {
        voltage = v; // Actualiza el estado con el nuevo voltaje
      });
    });
  });
}



  void toggleAllRelays() {
    bool newState = !relayStates.values.every((v) => v);
    relayStates.updateAll((key, value) => newState);

    setState(() {});
    _mqttService.publishRelay('relay/A', newState ? 'ON' : 'OFF');
    _mqttService.publishRelay('relay/B', newState ? 'ON' : 'OFF');
    _mqttService.publishRelay('relay/C', newState ? 'ON' : 'OFF');
  }

  void toggleRelay(String id) {
    setState(() {
      relayStates[id] = !(relayStates[id] ?? false);
    });
    _mqttService.publishRelay('relay/$id', relayStates[id]! ? 'ON' : 'OFF');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1B2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Text(
              'Reach',
              style: TextStyle(color: Colors.white),
            ),
            Icon(Icons.power, color: Colors.purpleAccent),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
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
                  icon: Icon(
                    Icons.power_settings_new,
                    color: relayStates.values.every((v) => v) ? Colors.red : Colors.purple,
                  ),
                  onPressed: toggleAllRelays,
                ),
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
                        value: 78.09,
                        needleColor: Colors.white,
                        needleStartWidth: 0.5,
                        needleEndWidth: 3,
                        needleLength: 0.8,
                        knobStyle: KnobStyle(
                          knobRadius: 0.01,
                          color: Color.fromARGB(255, 121, 67, 108),
                          borderColor: Colors.white,
                          borderWidth: 0.1,
                        ),
                        tailStyle: TailStyle(
                          color: Colors.white,
                          length: 0.2,
                          width: 3,
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
                _circularGauge('vol', voltage),
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
              child: ListView(
                children: ['A', 'B', 'C']
                    .map((id) => _outputTile('SALIDA ($id)', id))
                    .toList(),
              ),
            ),
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
  '$label\n${value.toStringAsFixed(2)}',
  textAlign: TextAlign.center,
  style: const TextStyle(color: Colors.white),
),
        )
      ],
    );
  }

  Widget _outputTile(String title, String id) {
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
          icon: Icon(
            Icons.power_settings_new,
            color: relayStates[id]! ? Colors.red : Colors.purple,
          ),
          onPressed: () => toggleRelay(id),
        ),
      ),
    );
  }
  
}

