import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'auth/register_screen.dart';
import 'services/device_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => DeviceController()..discoverDevice(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karmo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const RegisterScreen(), // or HomeScreen after login
    );
  }
}
