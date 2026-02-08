// import 'dart:async';
// import 'package:http/http.dart' as http;
//
// class DeviceDiscoveryService {
//   static const List<String> commonIps = [
//     '192.168.1.1',
//     '192.168.1.10',
//     '192.168.1.100',
//     '192.168.0.10',
//   ];
//
//   Future<String?> discover() async {
//     for (final ip in commonIps) {
//       try {
//         final res = await http
//             .get(Uri.parse('http://$ip/ping'))
//             .timeout(const Duration(milliseconds: 800));
//
//         if (res.statusCode == 200 && res.body == 'OK') {
//           return 'http://$ip';
//         }
//       } catch (_) {}
//     }
//     return null;
//   }
// }
