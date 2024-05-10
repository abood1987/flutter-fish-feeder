import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'mqtt_manager.dart';

class ScheduleModal {
  static void show(BuildContext context, MQTTManager mqttManager) {
    DateTime? _selectedTime;
    bool _repeat = false;
    String? _repeatFrequency;
    String? _errorMessage;
    final List<Map<String, String>> repeatOptions =
      [
        {'key': 'm', 'val': 'every minute'},
        {'key': 'h', 'val': 'every hour'},
        {'key': 'd', 'val': 'every day'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null)
                    Center(
                        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16))
                    ),
                  const Text("Schedule Feeding", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 20),
                  ListTile(
                    title: (_selectedTime != null)
                        ? Text('Selected Time: ${DateFormat('kk:mm').format(_selectedTime!)}')
                        : const Text('Select Time'),
                    trailing: const Icon(Icons.timer),
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setModalState(() {
                          DateTime now = DateTime.now();
                          _selectedTime = DateTime(now.year, now.month, now.day, pickedTime!.hour, pickedTime!.minute);
                          _errorMessage = null; // Reset error message when time is successfully picked
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text("Repeat"),
                    value: _repeat,
                    onChanged: (bool value) {
                      setModalState(() {
                        _repeat = value;
                        _errorMessage = null; // Reset error message when repeat is toggled
                      });
                    },
                  ),
                  if (_repeat) DropdownButton<String>(
                    value: _repeatFrequency,
                    hint: const Text('Select frequency'),
                    isExpanded: true,
                    items: repeatOptions.map((map) {
                      return DropdownMenuItem<String>(
                        value: map['key'],
                        child: Text(map['val']!),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setModalState(() {
                        _repeatFrequency = newValue;
                        _errorMessage = null; // Reset error message when frequency is selected
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedTime == null) {
                          setModalState(() {
                            _errorMessage = 'Time Field is required';
                          });
                        } else if (_repeat && _repeatFrequency == null) {
                          setModalState(() {
                            _errorMessage = 'Select frequency is required';
                          });
                        } else {
                          mqttManager.publishPlanTime(_selectedTime!.millisecondsSinceEpoch.toString());
                          if (_repeat && _repeatFrequency != null) {
                            mqttManager.publishPlanInterval(_repeatFrequency!);
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Confirm Schedule'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
