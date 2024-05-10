import 'package:fish_feeder/schedule_modal.dart';
import 'package:flutter/material.dart';
import 'device_data.dart';
import 'mqtt_manager.dart';

class DeviceStatusScreen extends StatefulWidget {
  const DeviceStatusScreen({super.key});

  @override
  _DeviceStatusScreenState createState() => _DeviceStatusScreenState();
}

class _DeviceStatusScreenState extends State<DeviceStatusScreen> {
  late MQTTManager mqttManager;
  int? _selectedNumber;
  String? _selectedUnit;
  final List<int> numbers = List.generate(10, (index) => index + 1);
  final List<String> units = ['days', 'hours', 'minutes'];

  @override
  void initState() {
    super.initState();
    mqttManager = MQTTManager();
    mqttManager.connect();
  }
  @override
  void dispose() {
    mqttManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fish Feeder")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreamBuilder<DeviceData>(
            stream: mqttManager.updates,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
                return Padding(
                    padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Text('Motor Status: ${snapshot.data!.motorStatus}'),
                      Text('Temperature: ${snapshot.data!.temperature.toStringAsFixed(1)}°C'),
                      Text('Current Plan: ${snapshot.data!.getPlanTime()} ${snapshot.data!.getPlanInterval()}'),
                      Text('Connection Status: ${snapshot.data!.connectionStatus}'),
                      (snapshot.data!.isLighting) ? const Text('Lights on') : const Text('Lights off')
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () => mqttManager.feedNow(),
                    child: const Text('Feed Now'),
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () => ScheduleModal.show(context, mqttManager),
                    child: const Text('Schedule'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => mqttManager.toggleLights(),
                    child: const Text('Toggle lights'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
