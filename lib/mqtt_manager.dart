import 'dart:async';
import 'dart:math';

import 'package:fish_feeder/constants.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'device_data.dart';

class MQTTManager {
  final String server;
  late MqttServerClient client;
  final StreamController<DeviceData> _controller = StreamController<DeviceData>.broadcast();
  String motorStatus = 'Stopped';
  double temperature = 0.0;
  String currentPlanTime = '';
  String currentPlanInterval = '';
  String connectionStatus = 'Disconnected';
  bool isLighting = false;

  MQTTManager({this.server='broker.hivemq.com'}) {
    client = MqttServerClient(server, generateClientId());
  }

  String generateClientId() {
    var random = Random();
    return 'flutter_client_${random.nextInt(10000)}';
  }

  Stream<DeviceData> get updates => _controller.stream;

  Future<void> connect() async {
    client.setProtocolV311();
    client.logging(on: false);
    client.onConnected = () {
      print('Client connected');
      connectionStatus = 'Connected';
      subscribeToTopics();
      _updateData();
    };
    client.onDisconnected = () {
      print('Client disconnected');
      connectionStatus = 'Disconnected';
      _updateData();
    };
    client.pongCallback = () {
      print('Ping response client callback invoked');
    };
    client.onSubscribed = onSubscribed;

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      connectionStatus = 'Disconnected';
      _updateData();
      client.disconnect();
    }
  }

  void subscribeToTopics() {
    client.subscribe(Constants.motorStatus, MqttQos.atLeastOnce);
    client.subscribe(Constants.temperature, MqttQos.atLeastOnce);
    client.subscribe(Constants.newPlanTime, MqttQos.atLeastOnce);
    client.subscribe(Constants.newPlanInterval, MqttQos.atLeastOnce);
    client.subscribe(Constants.toggleLight, MqttQos.atLeastOnce);
  }

  void onSubscribed(String topic) {
    print('Subscribed to $topic');
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
      final topicName = c[0].topic;

      if (topicName == Constants.motorStatus) {
        motorStatus = (int.parse(payload) == 1) ? 'Running' : 'Stopped';
      } else if (topicName == Constants.temperature) {
        temperature = double.parse(payload);
      } else if (topicName == Constants.newPlanTime) {
        currentPlanTime = payload;
      } else if (topicName == Constants.newPlanInterval) {
        currentPlanInterval = payload;
      } else if (topicName == Constants.toggleLight) {
        isLighting = (int.parse(payload) == 1) ? true : false;
      }

      _updateData();
    });
  }

  void _updateData() {
    _controller.sink.add(DeviceData(
      motorStatus: motorStatus,
      temperature: temperature,
      currentPlanTime: currentPlanTime,
      currentPlanInterval: currentPlanInterval,
      connectionStatus: connectionStatus,
      isLighting: isLighting
    ));
  }

  void dispose() {
    _controller.close();
    client.disconnect();
  }

  void publish(String topic, dynamic message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    print('Message published to $topic: $message');
  }

  void feedNow() {
    publish(Constants.feedNow, "1");
  }

  void toggleLights() {
    String status = (isLighting) ? "0" : "1";
    publish(Constants.toggleLight, status);
    isLighting = !isLighting;
  }

  void publishPlanTime(String status) {
    publish(Constants.newPlanTime, status);
  }

  void publishPlanInterval(String status) {
    publish(Constants.newPlanInterval, status);
  }
}
