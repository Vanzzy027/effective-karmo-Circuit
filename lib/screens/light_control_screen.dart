import 'package:flutter/material.dart';
import 'package:karmo/utils/ble_manager.dart';
import '../widgets/bulb_slider_card.dart';

class LightControlScreen extends StatefulWidget {
  const LightControlScreen({super.key});

  @override
  State<LightControlScreen> createState() => _LightControlScreenState();
}

class _LightControlScreenState extends State<LightControlScreen> {
  final BleManager _bleManager = BleManager();

  bool _isConnecting = true;
  bool _isConnected = false;

  final Map<int, int> _brightnessLevels = {
    1: 128,
    2: 200,
  };

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  Future<void> _connectToDevice() async {
    bool success = await _bleManager.connectToKarmo();

    if (success) {
      _bleManager.onStatusUpdate().listen((msg) {
        debugPrint("Received from ESP32: $msg");
        // Optionally update brightness from ESP32 here.
      });

      _bleManager.requestStatusAll();
    }

    setState(() {
      _isConnecting = false;
      _isConnected = success;
    });
  }

  void _onBrightnessChanged(int bulbID, int newValue) {
    setState(() {
      _brightnessLevels[bulbID] = newValue;
    });

    _bleManager.sendBrightness(bulbID, newValue);
  }

  @override
  void dispose() {
    _bleManager.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isConnecting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isConnected) {
      return Scaffold(
        appBar: AppBar(title: const Text("Light Control")),
        body: const Center(child: Text("Failed to connect to Karmo BLE.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Light Control")),
      body: ListView(
        children: _brightnessLevels.entries.map((entry) {
          return BulbSliderCard(
            bulbID: entry.key,
            brightness: entry.value,
            onBrightnessChanged: (val) =>
                _onBrightnessChanged(entry.key, val),
          );
        }).toList(),
      ),
    );
  }
}
