import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'auth/register_screen.dart';
import 'services/device_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final deviceController = DeviceController();
  await deviceController.start(); // 🔥 IMPORTANT

  runApp(
    ChangeNotifierProvider<DeviceController>.value(
      value: deviceController,
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const RegisterScreen(), // switch to HomeScreen after auth
    );
  }
}
