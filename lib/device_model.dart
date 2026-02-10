class DeviceModel {
  /// 🔒 Stable identity (comes from ESP)
  final String deviceId;

  /// 🏷 User-friendly name (editable later)
  final String name;

  /// 🌐 Current IP address (can change)
  String host;

  /// 🎛 Servo state
  int angle;

  /// 🔌 Live connectivity state
  bool isConnected;

  DeviceModel({
    required this.deviceId,
    required this.name,
    required this.host,
    this.angle = 90,
    this.isConnected = false,
  });

  // =========================
  // JSON → DeviceModel
  // =========================
  factory DeviceModel.fromJson(
      Map<String, dynamic> json, {
        required String host,
      }) {
    return DeviceModel(
      deviceId: json['deviceId'],
      name: json['name'] ?? 'Unknown Device',
      host: host,
      angle: json['angle'] ?? 90,
      isConnected: true,
    );
  }

  // =========================
  // DeviceModel → JSON (for persistence)
  // =========================
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'name': name,
      'host': host,
      'angle': angle,
    };
  }

  // =========================
  // Copy helper (safe updates)
  // =========================
  DeviceModel copyWith({
    String? host,
    int? angle,
    bool? isConnected,
  }) {
    return DeviceModel(
      deviceId: deviceId,
      name: name,
      host: host ?? this.host,
      angle: angle ?? this.angle,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
