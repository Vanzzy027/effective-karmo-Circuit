import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../device_model.dart';

class DeviceController extends ChangeNotifier {
  final List<DeviceModel> _devices = [];
  final Map<String, Timer> _pollers = {};
  final Map<String, int> _failureCount = {}; // for soft disconnect
  DateTime _lastScan = DateTime.fromMillisecondsSinceEpoch(0);

  bool isScanning = false;

  List<DeviceModel> get devices => List.unmodifiable(_devices);

  // =========================
  // LIFECYCLE
  // =========================

  Future<void> start() async {
    await _loadPairedDevices();
    await reconnectAll();
    await scanNetwork(); // Auto discovery on start
  }

  @override
  void dispose() {
    for (final t in _pollers.values) t.cancel();
    super.dispose();
  }

  // =========================
  // NETWORK SCAN (AUTO + MANUAL)
  // =========================

  /// Throttle scans: at least 5 seconds between scans
  Future<void> scanNetwork() async {
    final now = DateTime.now();
    if (isScanning || now.difference(_lastScan).inSeconds < 5) return;

    isScanning = true;
    _lastScan = now;
    notifyListeners();

    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );

      final wifiInterface = interfaces.firstWhere(
            (i) => i.name.toLowerCase().contains('wlan') ||
            i.name.toLowerCase().contains('wi-fi'),
        orElse: () => interfaces.first,
      );

      final ip = wifiInterface.addresses.first.address;
      final subnet = ip.substring(0, ip.lastIndexOf('.'));

      final futures = <Future>[];
      for (int i = 1; i < 255; i++) {
        final host = '$subnet.$i';
        futures.add(tryPair(host));
      }

      await Future.wait(futures);
    } finally {
      isScanning = false;
      notifyListeners();
    }
  }

  // =========================
  // PAIRING
  // =========================

  Future<void> tryPair(String host) async {
    try {
      final res = await http
          .get(Uri.parse('http://$host/getState'))
          .timeout(const Duration(seconds: 2));

      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body);
      final device = DeviceModel.fromJson(data, host: host);

      final index = _devices.indexWhere((d) => d.deviceId == device.deviceId);

      if (index >= 0) {
        _devices[index]
          ..host = host
          ..isConnected = true;
      } else {
        _devices.add(device);
      }

      await _persistDevices();
      _startPolling(device.deviceId);

      notifyListeners();
    } catch (_) {
      // ignore failures
    }
  }

  // =========================
  // RECONNECT
  // =========================

  Future<void> reconnectAll() async {
    for (final d in _devices) {
      await _reconnectDevice(d);
    }
  }

  Future<void> _reconnectDevice(DeviceModel device) async {
    try {
      final res = await http
          .get(Uri.parse('http://${device.host}/getState'))
          .timeout(const Duration(seconds: 2));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        device.angle = data['angle'] ?? device.angle;
        device.isConnected = true;
        _startPolling(device.deviceId);
      } else {
        device.isConnected = false;
      }
    } catch (_) {
      device.isConnected = false;
    }

    notifyListeners();
  }

  // =========================
  // POLLING WITH SOFT DISCONNECT
  // =========================

  void _startPolling(String deviceId) {
    _pollers[deviceId]?.cancel();
    _failureCount[deviceId] = 0;

    _pollers[deviceId] = Timer.periodic(
      const Duration(seconds: 8),
          (_) => _pollDevice(deviceId),
    );
  }

  Future<void> _pollDevice(String deviceId) async {
    final device = _devices.firstWhere((d) => d.deviceId == deviceId);

    try {
      final res = await http
          .get(Uri.parse('http://${device.host}/getState'))
          .timeout(const Duration(seconds: 2));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        device.angle = data['angle'] ?? device.angle;
        device.isConnected = true;
        _failureCount[deviceId] = 0;
        notifyListeners();
      } else {
        _failureCount[deviceId] = (_failureCount[deviceId] ?? 0) + 1;
        if (_failureCount[deviceId]! >= 3) {
          device.isConnected = false;
          notifyListeners();
        }
      }
    } catch (_) {
      _failureCount[deviceId] = (_failureCount[deviceId] ?? 0) + 1;
      if (_failureCount[deviceId]! >= 3) {
        device.isConnected = false;
        notifyListeners();
      }
    }
  }

  // =========================
  // CONTROL
  // =========================

  Future<void> setAngle(String deviceId, int angle) async {
    final device = _devices.firstWhere((d) => d.deviceId == deviceId);

    if (!device.isConnected) return;

    try {
      final res = await http.get(
        Uri.parse('http://${device.host}/setServo?angle=$angle'),
      );

      if (res.statusCode == 200) {
        device.angle = angle;
        notifyListeners();
      } else {
        device.isConnected = false;
        notifyListeners();
      }
    } catch (_) {
      device.isConnected = false;
      notifyListeners();
    }
  }

  // =========================
  // STORAGE
  // =========================

  Future<void> _persistDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _devices.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList('paired_devices', list);
  }

  Future<void> _loadPairedDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('paired_devices') ?? [];

    _devices.clear();

    for (final j in list) {
      final d = jsonDecode(j);
      _devices.add(
        DeviceModel(
          deviceId: d['deviceId'],
          name: d['name'],
          host: d['host'],
          angle: d['angle'],
          isConnected: false,
        ),
      );
    }
  }
}
