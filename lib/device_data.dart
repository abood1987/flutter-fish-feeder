import 'package:intl/intl.dart';

class DeviceData {
  final String motorStatus; // Indicates if the motor is "Running" or "Stopped"
  final double temperature; // Current temperature reading
  final String currentPlanTime; // Describes the feeding schedule
  final String currentPlanInterval; // Describes the feeding schedule
  final String connectionStatus; // MQTT connection status: "Connected", "Disconnected", etc.
  final bool isLighting;

  DeviceData({
    required this.motorStatus,
    required this.temperature,
    required this.currentPlanTime,
    required this.currentPlanInterval,
    required this.connectionStatus,
    required this.isLighting,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      motorStatus: json['motorStatus'] as String,
      temperature: double.parse(json['temperature'].toString()),
      currentPlanTime: json['newPlanTime'] as String,
      currentPlanInterval: json['newPlanInterval'] as String,
      connectionStatus: json['connectionStatus'] as String,
      isLighting: json['isLighting'] as bool,
    );
  }

  getPlanTime() {
    if (currentPlanTime == '') {
      return 'Unset';
    } else if (currentPlanInterval == 'h' || currentPlanInterval == 'm') {
      return '';
    }
    return DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(int.parse(currentPlanTime)));
  }

  getPlanInterval() {
    switch(currentPlanInterval) {
      case 'd':
        return 'Every day';
      case 'h':
        return 'Every hour';
      case 'm':
        return 'Every minute';
      default:
        return '';
    }
  }
}
