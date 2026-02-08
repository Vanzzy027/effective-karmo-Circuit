// import 'dart:async';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class BleService {
//   BluetoothDevice? _device;
//   BluetoothCharacteristic? _txChar;
//   BluetoothCharacteristic? _rxChar;
//
//   final StreamController<String> _statusController = StreamController.broadcast();
//   Stream<String> get onStatusUpdate => _statusController.stream;
//
//   Future<bool> connectToKarmo() async {
//     try {
//       // Start BLE scan
//       FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
//
//       // Set up scan listener
//       BluetoothDevice? targetDevice;
//       StreamSubscription? scanSubscription;
//       final completer = Completer<bool>();
//
//       scanSubscription = FlutterBluePlus.scanResults.listen((results) {
//         for (ScanResult result in results) {
//           final device = result.device;
//           // Use platformName instead of deprecated name
//           if (device.platformName.isNotEmpty && device.platformName == 'MovanESP') {
//             targetDevice = device;
//             FlutterBluePlus.stopScan();
//             scanSubscription?.cancel();
//             completer.complete(true);
//           }
//         }
//       });
//
//       // Timeout handling
//       Timer(const Duration(seconds: 4), () {
//         if (!completer.isCompleted) {
//           FlutterBluePlus.stopScan();
//           scanSubscription?.cancel();
//           completer.complete(false);
//         }
//       });
//
//       // Wait for scan completion
//       final foundDevice = await completer.future;
//       if (!foundDevice || targetDevice == null) {
//         _statusController.add('Device not found');
//         return false;
//       }
//
//       // Connect to device
//       _device = targetDevice;
//       await _device!.connect();
//
//       // Discover services
//       List<BluetoothService> services = await _device!.discoverServices();
//       for (var service in services) {
//         for (var char in service.characteristics) {
//           if (char.properties.write) _txChar = char;
//           if (char.properties.notify) {
//             _rxChar = char;
//             await _rxChar!.setNotifyValue(true);
//             // Use lastValueStream instead of deprecated value
//             _rxChar!.lastValueStream.listen((value) {
//               _statusController.add(String.fromCharCodes(value));
//             });
//           }
//         }
//       }
//
//       return true;
//     } catch (e) {
//       _statusController.add('BLE Error: $e');
//       return false;
//     }
//   }
// // In both ble_service.dart and ble_manager.dart, replace the write methods with:
//
//   void sendBrightness(int bulbId, int brightness) {
//     if (_txChar == null) return;
//     String command = "BULB:$bulbId:$brightness";
//
//     try {
//       // Try different write methods
//       if (_txChar!.properties.write) {
//         _txChar!.write(command.codeUnits);
//       } else if (_txChar!.properties.writeWithoutResponse) {
//         _txChar!.write(command.codeUnits, withoutResponse: true);
//       }
//     } catch (e) {
//       print('Write error: $e');
//     }
//   }
//
//   void requestStatusAll() {
//     if (_txChar == null) return;
//
//     try {
//       if (_txChar!.properties.write) {
//         _txChar!.write("STATUS".codeUnits);
//       } else if (_txChar!.properties.writeWithoutResponse) {
//         _txChar!.write("STATUS".codeUnits, withoutResponse: true);
//       }
//     }
//     catch (e) {
//       print('Write error: $e');
//     }
//   }
// }