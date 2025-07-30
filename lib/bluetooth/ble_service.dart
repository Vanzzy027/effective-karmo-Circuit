import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEService {
  static final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  static BluetoothDevice? connectedDevice;
  static BluetoothCharacteristic? brightnessChar;

  static const String espDeviceName = "KARMO-ESP32"; // ESP32 BLE Name
  static const String serviceUUID = "19b10000-e8f2-537e-4f6c-d104768a1214";
  static const String characteristicUUID = "19b10001-e8f2-537e-4f6c-d104768a1214";

  static Future<void> scanAndConnect() async {
    _flutterBlue.startScan(timeout: const Duration(seconds: 5));

    await for (ScanResult result in _flutterBlue.scanResults.expand((r) => r)) {
      if (result.device.name == espDeviceName) {
        await _flutterBlue.stopScan();
        connectedDevice = result.device;
        await connectedDevice!.connect();
        await _discoverServices();
        break;
      }
    }
  }

  static Future<void> _discoverServices() async {
    if (connectedDevice == null) return;

    List<BluetoothService> services = await connectedDevice!.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == serviceUUID) {
        for (var char in service.characteristics) {
          if (char.uuid.toString() == characteristicUUID) {
            brightnessChar = char;
            await brightnessChar!.setNotifyValue(true);
            brightnessChar!.value.listen((value) {
              String msg = utf8.decode(value);
              print("Received from ESP: $msg");
              // You can now sync brightness level from ESP
            });
            break;
          }
        }
      }
    }
  }

  static Future<void> sendBrightness(int bulbIndex, int brightness) async {
    if (brightnessChar == null) return;
    final data = utf8.encode("BRIGHTNESS$bulbIndex:$brightness\n");
    await brightnessChar!.write(data, withoutResponse: true);
  }

  static Future<void> disconnect() async {
    await connectedDevice?.disconnect();
    connectedDevice = null;
    brightnessChar = null;
  }
}
