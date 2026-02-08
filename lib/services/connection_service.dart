abstract class ConnectionService {
  Future<bool> connect();
  Future<void> disconnect();
  Future<void> sendCommand(String command);
  Stream<String> get onData;
}
