import 'dart:async';
import 'package:http/http.dart' as http;
import 'connection_service.dart';

class WifiConnectionService implements ConnectionService {
  final String baseUrl;
  final StreamController<String> _controller =
  StreamController<String>.broadcast();

  WifiConnectionService(this.baseUrl);

  @override
  Stream<String> get onData => _controller.stream;

  @override
  Future<bool> connect() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/ping'))
          .timeout(const Duration(seconds: 2));

      return res.statusCode == 200;
    } catch (e) {
      _controller.add('WIFI_CONNECT_ERROR');
      return false;
    }
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> sendCommand(String command) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/$command'))
          .timeout(const Duration(seconds: 2));

      if (res.statusCode == 200) {
        _controller.add(res.body);
      }
    } catch (e) {
      _controller.add('COMMAND_FAILED');
    }
  }
}
