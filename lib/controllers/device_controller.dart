// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../device_model.dart';
//
// class DeviceController extends ChangeNotifier {
//   // =========================
//   // STATE
//   // =========================
//
//   final List<DeviceModel> _devices = [];
//   final Map<String, Timer> _pollers = {};
//
//   bool isScanning = false;
//
//   List<DeviceModel> get devices => List.unmodifiable(_devices);
//
//   // =========================
//   // LIFECYCLE
//   // =========================
//
//   Future<void> start() async {
//     await _loadPairedDevices();
//     await reconnectAll();
//   }
//
//   @override
//   void dispose() {
//     for (final timer in _pollers.values) {
//       timer.cancel();
//     }
//     super.dispose();
//   }
//
//   // =========================
//   // PAIRING & DISCOVERY
//   // =========================
//
//   /// Try a specific IP (manual or scan result)
//   Future<void> tryPair(String host) async {
//     try {
//       final res = await http
//           .get(Uri.parse('http://$host/getState'))
//           .timeout(const Duration(seconds: 2));
//
//       if (res.statusCode != 200) return;
//
//       final data = jsonDecode(res.body);
//
//       final device = DeviceModel.fromJson(
//         data,
//         host: host,
//       );
//
//       final index =
//       _devices.indexWhere((d) => d.deviceId == device.deviceId);
//
//       if (index >= 0) {
//         // 🔁 Known device, update IP
//         _devices[index].host = host;
//         _devices[index].isConnected = true;
//       } else {
//         // 🆕 New device → auto-pair
//         _devices.add(device);
//       }
//
//       await _persistDevices();
//       _startPolling(device.deviceId);
//
//       notifyListeners();
//     } catch (_) {
//       // silent fail (expected during scans)
//     }
//   }
//
//   // =========================
//   // RECONNECTION
//   // =========================
//
//   Future<void> reconnectAll() async {
//     for (final device in _devices) {
//       await _reconnectDevice(device);
//     }
//   }
//
//   Future<void> _reconnectDevice(DeviceModel device) async {
//     try {
//       final res = await http
//           .get(Uri.parse('http://${device.host}/getState'))
//           .timeout(const Duration(seconds: 2));
//
//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body);
//         device.angle = data['angle'] ?? device.angle;
//         device.isConnected = true;
//         _startPolling(device.deviceId);
//       } else {
//         device.isConnected = false;
//       }
//     } catch (_) {
//       device.isConnected = false;
//     }
//
//     notifyListeners();
//   }
//
//   // =========================
//   // POLLING (PER DEVICE)
//   // =========================
//
//   void _startPolling(String deviceId) {
//     _pollers[deviceId]?.cancel();
//
//     _pollers[deviceId] = Timer.periodic(
//       const Duration(seconds: 3),
//           (_) => _pollDevice(deviceId),
//     );
//   }
//
//   Future<void> _pollDevice(String deviceId) async {
//     final device =
//     _devices.firstWhere((d) => d.deviceId == deviceId);
//
//     if (!device.isConnected) return;
//
//     try {
//       final res = await http
//           .get(Uri.parse('http://${device.host}/getState'))
//           .timeout(const Duration(seconds: 2));
//
//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body);
//         device.angle = data['angle'] ?? device.angle;
//         notifyListeners();
//       } else {
//         device.isConnected = false;
//       }
//     } catch (_) {
//       device.isConnected = false;
//       notifyListeners();
//     }
//   }
//
//   // =========================
//   // SERVO CONTROL (WRITE)
//   // =========================
//
//   Future<void> setAngle(String deviceId, int angle) async {
//     final device =
//     _devices.firstWhere((d) => d.deviceId == deviceId);
//
//     if (!device.isConnected) return;
//
//     try {
//       final res = await http.get(
//         Uri.parse(
//           'http://${device.host}/setServo?angle=$angle',
//         ),
//       );
//
//       if (res.statusCode == 200) {
//         device.angle = angle;
//         notifyListeners();
//       }
//     } catch (_) {
//       device.isConnected = false;
//       notifyListeners();
//     }
//   }
//
//   // =========================
//   // PERSISTENCE
//   // =========================
//
//   Future<void> _persistDevices() async {
//     final prefs = await SharedPreferences.getInstance();
//     final jsonList =
//     _devices.map((d) => jsonEncode(d.toJson())).toList();
//     await prefs.setStringList('paired_devices', jsonList);
//   }
//
//   Future<void> _loadPairedDevices() async {
//     final prefs = await SharedPreferences.getInstance();
//     final jsonList = prefs.getStringList('paired_devices') ?? [];
//
//     _devices.clear();
//
//     for (final jsonStr in jsonList) {
//       final data = jsonDecode(jsonStr);
//       _devices.add(
//         DeviceModel(
//           deviceId: data['deviceId'],
//           name: data['name'],
//           host: data['host'],
//           angle: data['angle'],
//           isConnected: false,
//         ),
//       );
//     }
//   }
// }
