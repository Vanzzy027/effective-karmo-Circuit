import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class AuthService {
  static const String _userKey = 'karmo_users';
  static const String _currentUserKey = 'karmo_current_user';

  /// ✅ Public static method to register a user
  static Future<String?> registerUser(String username, String password) async {
    final service = AuthService();
    return await service._register(username, password);
  }

  /// ✅ Get all saved users from storage
  Future<List<Map<String, String>>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_userKey);

    if (usersJson == null || usersJson.isEmpty) return [];

    final decoded = json.decode(usersJson);

    // Safely decode to list of string maps
    if (decoded is List) {
      return decoded
          .map<Map<String, String>>((item) =>
      Map<String, String>.from(item as Map))
          .toList();
    }

    return [];
  }

  /// ✅ Save user list to SharedPreferences
  Future<void> _saveUsers(List<Map<String, String>> users) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(users);
    await prefs.setString(_userKey, encoded);
  }

  /// ✅ Private method to handle registration logic
  Future<String?> _register(String username, String password) async {
    final users = await _getUsers();

    if (users.length >= 10) return 'Max 10 accounts allowed';
    if (users.any((user) => user['username'] == username)) {
      return 'Username already exists';
    }

    users.add({'username': username, 'password': password});
    await _saveUsers(users);
    return null; // success
  }

  /// ✅ Login and store current user if successful
  Future<bool> login(String username, String password) async {
    final users = await _getUsers();
    final match = users.any((user) =>
    user['username'] == username && user['password'] == password);

    if (match) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, username);
    }

    return match;
  }

  /// ✅ Get list of usernames for UI selection
  Future<List<String>> getUsernames() async {
    final users = await _getUsers();
    return users.map((user) => user['username']!).toList();
  }

  /// ✅ Get currently logged-in username
  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  /// ✅ Clear session and navigate to login screen
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }
}
