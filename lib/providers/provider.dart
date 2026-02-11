// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ThemeProvider extends ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.system;
//
//   ThemeProvider() {
//     _loadTheme();
//   }
//
//   ThemeMode get themeMode => _themeMode;
//
//   void toggleTheme(bool isDark) {
//     _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
//     _saveTheme(isDark);
//     notifyListeners();
//   }
//
//   void _loadTheme() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool? isDark = prefs.getBool('isDark');
//     _themeMode = (isDark ?? false) ? ThemeMode.dark : ThemeMode.light;
//     notifyListeners();
//   }
//
//   void _saveTheme(bool isDark) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isDark', isDark);
//   }
// }
