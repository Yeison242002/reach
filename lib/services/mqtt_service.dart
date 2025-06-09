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
}
