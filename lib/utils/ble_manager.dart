import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleManager {
  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  late BluetoothDevice _device;
  late BluetoothCharacteristic _txChar;
  late BluetoothCharacteristic _rxChar;

  final StreamController<String> _statusController = StreamController.broadcast();
  Stream<String> onStatusUpdate() => _statusController.stream;

  Future<bool> connectToKarmo() async {
    try {
      await flutterBlue.startScan(timeout: const Duration(seconds: 4));

      final scanResult = await flutterBlue.scanResults.firstWhere(
            (results) => results.any((r) => r.device.name == 'MovanESP'),
      );

      _device = scanResult.firstWhere((r) => r.device.name == 'MovanESP').device;

      await flutterBlue.stopScan();
      await _device.connect();

      List<BluetoothService> services = await _device.discoverServices();
      for (var service in services) {
        for (var char in service.characteristics) {
          if (char.properties.write) _txChar = char;
          if (char.properties.notify) {
            _rxChar = char;
            await _rxChar.setNotifyValue(true);
            _rxChar.value.listen((value) {
              _statusController.add(String.fromCharCodes(value));
            });
          }
        }
      }

      return true;
    } catch (e) {
      print('BLE Error: $e');
      return false;
    }
  }

  void sendBrightness(int bulbId, int brightness) {
    String command = "BULB:$bulbId:$brightness";
    _txChar.write(command.codeUnits);
  }

  void requestStatusAll() {
    _txChar.write("STATUS".codeUnits);
  }

  void disconnect() {
    _device.disconnect();
  }
}
