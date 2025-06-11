import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  final client = MqttServerClient(
    'broker.hivemq.com',
    'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
  );

  Future<void> connect() async {
    client.port = 1883;
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = () => print('MQTT Disconnected');
    client.onConnected = () => print('MQTT Connected');

    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_app')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMess;

    try {
      print('Connecting to MQTT broker...');
      await client.connect();
      if (client.connectionStatus!.state != MqttConnectionState.connected) {
        print('Connection failed - status: ${client.connectionStatus!.state}');
        client.disconnect();
      }
    } catch (e) {
      print('MQTT connection error: $e');
      client.disconnect();
    }
  }

  void publishRelay(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    print('Published "$message" to $topic');
  }

  void subscribeToVoltage(Function(double voltage) onVoltageUpdated) {
  const voltageTopic = 'sensor/voltage';
  
  client.subscribe(voltageTopic, MqttQos.atLeastOnce);
  
  client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    final recMess = c[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    final topic = c[0].topic;

    if (topic == voltageTopic) {
      try {
        final voltage = double.parse(payload);
        onVoltageUpdated(voltage);
      } catch (e) {
        print('Error al parsear voltaje: $e');
      }
    }
  });
}
void subscribeToTotalCurrent(Function(double current) onCurrentUpdated) {
  const currentTopic = 'sensor/current_total';

  client.subscribe(currentTopic, MqttQos.atLeastOnce);

  client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    final recMess = c[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    final topic = c[0].topic;

    if (topic == currentTopic) {
      try {
        final current = double.parse(payload);
        onCurrentUpdated(current);
      } catch (e) {
        print('Error al parsear corriente total: $e');
      }
    }
  });
}
void subscribeToOutputData({
  required Function(String id, double watts, double volts, double amps) onData,
}) {
  const topics = [
    'sensor/watts_a',
    'sensor/voltage_a',
    'sensor/current_a',
    'sensor/watts_b',
    'sensor/voltage_b',
    'sensor/current_b',
    'sensor/watts_c',
    'sensor/voltage_c',
    'sensor/current_c',
  ];

  for (var topic in topics) {
    client.subscribe(topic, MqttQos.atLeastOnce);
  }

  final Map<String, double> _a = {}, _b = {}, _c = {};

  client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
    final recMess = c[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    final topic = c[0].topic;

    try {
      final value = double.parse(payload);
      if (topic.endsWith('_a')) _a[topic.split('/').last] = value;
      if (topic.endsWith('_b')) _b[topic.split('/').last] = value;
      if (topic.endsWith('_c')) _c[topic.split('/').last] = value;

      if (_a.length == 3) onData('A', _a['watts_a']!, _a['voltage_a']!, _a['current_a']!);
      if (_b.length == 3) onData('B', _b['watts_b']!, _b['voltage_b']!, _b['current_b']!);
      if (_c.length == 3) onData('C', _c['watts_c']!, _c['voltage_c']!, _c['current_c']!);
    } catch (e) {
      print('Error parsing MQTT payload: $e');
    }
  });
}

}
