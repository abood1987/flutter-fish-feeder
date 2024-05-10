import 'package:flutter/material.dart';
import 'device_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          labelLarge: TextStyle(fontSize: 20),
          bodyMedium: TextStyle(fontSize: 20)
        )
      ),
      // home: const HomeScreen(),
      home: DeviceStatusScreen(),
    );
  }
}
