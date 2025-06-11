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

  Map<String, Map<String, double>> outputData = {
  'A': {'watts': 0.0, 'volts': 0.0, 'amps': 0.0},
  'B': {'watts': 0.0, 'volts': 0.0, 'amps': 0.0},
  'C': {'watts': 0.0, 'volts': 0.0, 'amps': 0.0},
};

  double voltage = 0.0;
  double totalCurrent = 0.0;


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
  _mqttService.subscribeToTotalCurrent((double current) {
  setState(() {
    totalCurrent = current;
  });
});
_mqttService.subscribeToOutputData(
  onData: (id, watts, volts, amps) {
    setState(() {
      outputData[id] = {'watts': watts, 'volts': volts, 'amps': amps};
    });
  },
);
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
  final newState = !(relayStates[id] ?? false);
  setState(() {
    relayStates[id] = newState;
  });
  _mqttService.publishRelay('relay/$id', newState ? 'ON' : 'OFF');
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
        maximum: 150, // Ajusta si esperas más consumo
        ranges: <GaugeRange>[
          GaugeRange(startValue: 0, endValue: 50, color: Colors.green),
          GaugeRange(startValue: 50, endValue: 100, color: Colors.yellow),
          GaugeRange(startValue: 100, endValue: 150, color: Colors.red),
        ],
        pointers: <GaugePointer>[
          NeedlePointer(
            value: (voltage * totalCurrent).clamp(0, 150),
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
              '${(voltage * totalCurrent).toStringAsFixed(2)}\nwatts',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
                _circularGauge('A', totalCurrent),

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
  final data = outputData[id]!;

  return Card(
    color: const Color(0xFF3A2F54),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        'Watts: ${data['watts']!.toStringAsFixed(1)}    Vol: ${data['volts']!.toStringAsFixed(1)}    A: ${data['amps']!.toStringAsFixed(1)}',
        style: const TextStyle(color: Colors.white),  
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

