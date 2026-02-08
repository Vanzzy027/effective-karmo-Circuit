import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../device_model.dart';

class DeviceController extends ChangeNotifier {
  // =========================
  // STATE
  // =========================

  List<DeviceModel> devices = [];
  bool isConnected = false;
  bool isScanning = false;

  // 🔥 HARD-CODED ESP IP (change if needed)
  final String _deviceUrl = 'http://10.212.115.217';

  Timer? _pollTimer;

  // =========================
  // INIT
  // =========================

  void init() {
    discoverDevice();
    _startPolling();
  }

  // =========================
  // DISCOVERY (ONE JOB ONLY)
  // =========================

  Future<void> discoverDevice() async {
    if (isScanning) return;

    isScanning = true;
    notifyListeners();

    try {
      final res = await http
          .get(Uri.parse('$_deviceUrl/getState'))
          .timeout(const Duration(seconds: 2));

      if (res.statusCode == 200) {
        final angle = int.tryParse(
          RegExp(r'"angle"\s*:\s*(\d+)')
              .firstMatch(res.body)
              ?.group(1) ??
              '',
        ) ??
            90;

        devices = [
          DeviceModel(
            name: 'ESP Bulb',
            angle: angle,
            isConnected: true,
          ),
        ];
        isConnected = true;
      } else {
        _markOffline();
      }
    } catch (_) {
      _markOffline();
    }

    isScanning = false;
    notifyListeners();
  }

  void _markOffline() {
    devices = [];
    isConnected = false;
  }

  // =========================
  // STATE POLLING (READ ONLY)
  // =========================

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 3),
          (_) => _pollState(),
    );
  }

  Future<void> _pollState() async {
    if (!isConnected) return;

    try {
      final res = await http
          .get(Uri.parse('$_deviceUrl/getState'))
          .timeout(const Duration(seconds: 2));

      if (res.statusCode == 200 && devices.isNotEmpty) {
        final angle = int.tryParse(
          RegExp(r'"angle"\s*:\s*(\d+)')
              .firstMatch(res.body)
              ?.group(1) ??
              '',
        ) ??
            devices.first.angle;

        devices.first.angle = angle;
        notifyListeners();
      }
    } catch (_) {
      _markOffline();
      notifyListeners();
    }
  }

  // =========================
  // SERVO CONTROL (WRITE)
  // =========================

  Future<void> setAngle(int angle) async {
    if (!isConnected) return;

    try {
      final res = await http.get(
        Uri.parse('$_deviceUrl/setServo?angle=$angle'),
      );

      if (res.statusCode == 200 && devices.isNotEmpty) {
        devices.first.angle = angle;
        notifyListeners();
      }
    } catch (_) {
      _markOffline();
      notifyListeners();
    }
  }

  // =========================
  // CLEANUP
  // =========================

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
