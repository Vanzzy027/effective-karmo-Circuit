import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:http/http.dart' as http;
import '../device_model.dart';

class DeviceController extends ChangeNotifier {
  // =========================
  // STATE
  // =========================

  List<DeviceModel> devices = [];
  bool isConnected = false;
  bool isScanning = false;

  String? _deviceUrl;
  Timer? _autoScanTimer;

  // =========================
  // PUBLIC API
  // =========================

  /// Call this ONCE from HomeScreen init
  void init() {
    discoverDevices();
    _startAutoScan();
  }

  /// Manual or automatic discovery
  Future<void> discoverDevices() async {
    if (isScanning) return;

    isScanning = true;
    notifyListeners(); // 🔴 FORCE spinner to appear

    // Give Flutter ONE frame to paint spinner
    await Future.delayed(const Duration(milliseconds: 100));

    String? foundUrl;

    // 1️⃣ Try mDNS
    foundUrl = await _discoverViaMDns();

    // 2️⃣ Fallback LAN scan
    foundUrl ??= await _scanLAN();

    if (foundUrl != null) {
      _deviceUrl = foundUrl;
      devices = [
        DeviceModel(
          name: 'ESP Bulb',
          angle: devices.isNotEmpty ? devices.first.angle : 0,
          isConnected: true,
        ),
      ];
      isConnected = true;
    } else {
      devices = [];
      isConnected = false;
    }

    isScanning = false;
    notifyListeners(); // 🔴 Update UI
  }

  /// Send servo angle
  Future<void> setAngle(int angle) async {
    if (_deviceUrl == null) return;

    try {
      final res = await http.get(
        Uri.parse('$_deviceUrl/setServo?angle=$angle'),
      );

      if (res.statusCode == 200 && devices.isNotEmpty) {
        devices[0].angle = angle;
        notifyListeners();
      }
    } catch (_) {
      isConnected = false;
      notifyListeners();
    }
  }

  /// Call when leaving HomeScreen
  void disposeController() {
    _autoScanTimer?.cancel();
  }

  // =========================
  // AUTO RESCAN (OFFLINE ONLY)
  // =========================

  void _startAutoScan() {
    _autoScanTimer?.cancel();
    _autoScanTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) {
        if (!isConnected && !isScanning) {
          discoverDevices();
        }
      },
    );
  }

  // =========================
  // DISCOVERY IMPLEMENTATION
  // =========================

  Future<String?> _discoverViaMDns() async {
    try {
      final client = MDnsClient();
      await client.start();

      await for (final PtrResourceRecord ptr
      in client.lookup<PtrResourceRecord>(
          ResourceRecordQuery.serverPointer('_http._tcp.local'))) {
        await for (final SrvResourceRecord srv
        in client.lookup<SrvResourceRecord>(
            ResourceRecordQuery.service(ptr.domainName))) {
          client.stop();
          return 'http://${srv.target}:${srv.port}';
        }
      }

      client.stop();
    } catch (e) {
      debugPrint('mDNS failed: $e');
    }
    return null;
  }

  Future<String?> _scanLAN() async {
    const subnet = '10.212.115.'; // ⚠️ hotspot dependent

    for (int i = 1; i < 255; i++) {
      final ip = '$subnet$i';
      try {
        final res = await http
            .get(Uri.parse('http://$ip/setServo?angle=90'))
            .timeout(const Duration(milliseconds: 250));

        if (res.statusCode == 200) {
          return 'http://$ip';
        }
      } catch (_) {}
    }
    return null;
  }
}
