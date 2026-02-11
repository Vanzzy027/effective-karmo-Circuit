import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'auth/register_screen.dart';
import 'services/device_controller.dart';
import 'providers/theme_provider.dart'; // 🔥 new import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final deviceController = DeviceController();
  await deviceController.start(); // 🔥 IMPORTANT

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DeviceController>.value(value: deviceController),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Karmo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFF121416),
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
            ),
          ),
          themeMode: themeProvider.themeMode, // 🔥 auto-sync with saved or system
          home: const RegisterScreen(), // switch to HomeScreen after auth
        );
      },
    );
  }
}
