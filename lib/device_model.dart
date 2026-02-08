class DeviceModel {
  final String name;
  final String host; // required
  int angle;
  bool isConnected;

  DeviceModel({
    required this.name,
    this.host = '0.0.0.0', // fallback if unknown
    this.angle = 90,
    this.isConnected = false,
  });
}
