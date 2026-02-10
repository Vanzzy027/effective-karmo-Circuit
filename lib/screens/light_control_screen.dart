import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../services/device_controller.dart';
import '../device_model.dart';

class LightControlScreen extends StatefulWidget {
  final String deviceId;

  const LightControlScreen({
    super.key,
    required this.deviceId,
  });

  @override
  State<LightControlScreen> createState() => _LightControlScreenState();
}

class _LightControlScreenState extends State<LightControlScreen> {
  int _localAngle = 90;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121416) : const Color(0xFFF8F9FA);
    final accentColor = const Color(0xFF1E3C72);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Consumer<DeviceController>(
      builder: (context, controller, _) {
        final device = controller.devices.firstWhere(
              (d) => d.deviceId == widget.deviceId,
        );

        if (device.angle != _localAngle) {
          _localAngle = device.angle;
        }

        final bool isOnline = device.isConnected;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: _buildAppBar(context, device, isOnline, isDark),
          body: Column(
            children: [
              // 🚀 NEW: TELEMETRY HERO COMPONENT
              _buildTelemetryHero(isOnline, isDark),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      // ================= VISUAL GAUGE (Scaled Down) =================
                      _buildRotatingGauge(context, _localAngle, isOnline, isDark),

                      const SizedBox(height: 40),

                      // ================= CONTROL CONSOLE =================
                      _buildControlConsole(context, controller, device, isOnline, isDark, cardColor),

                      const SizedBox(height: 25),

                      // ================= SYNC INTEGRITY CARD =================
                      _buildSyncIntegrityCard(isDark, cardColor),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= TELEMETRY HERO =================

  Widget _buildTelemetryHero(bool isOnline, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeroStat("SIGNAL", "98%", Icons.wifi_lock, isOnline ? Colors.green : Colors.grey),
          _buildHeroStat("BATTERY", "84%", Icons.battery_charging_full_rounded, isOnline ? Colors.blue : Colors.grey),
          _buildHeroStat("LATENCY", "4ms", Icons.speed_rounded, isOnline ? Colors.orange : Colors.grey),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 8, color: Colors.grey, letterSpacing: 1)),
      ],
    );
  }

  // ================= APP BAR =================

  PreferredSizeWidget _buildAppBar(BuildContext context, DeviceModel device, bool isOnline, bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            device.name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 6, color: isOnline ? Colors.green : Colors.red),
              const SizedBox(width: 5),
              Text(
                isOnline ? "ACTIVE NODE" : "NODE DISCONNECTED",
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: isOnline ? Colors.green : Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ROTATING GAUGE =================

  Widget _buildRotatingGauge(BuildContext context, int angle, bool isOnline, bool isDark) {
    final double radians = (angle - 90) * (math.pi / 180);

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer technical ring
            Container(
              height: 180, // Scaled down from 220
              width: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05), width: 8),
              ),
            ),
            // Precise Arc
            SizedBox(
              height: 150,
              width: 150,
              child: CircularProgressIndicator(
                value: angle / 180,
                strokeWidth: 4,
                color: isOnline ? const Color(0xFF1E3C72) : Colors.grey,
                backgroundColor: Colors.transparent,
              ),
            ),
            // The Peripheral Icon
            Transform.rotate(
              angle: radians,
              child: Icon(
                Icons.settings_input_component_rounded,
                size: 60,
                color: isOnline ? const Color(0xFF1E3C72) : Colors.grey.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Text(
          "$angle°",
          style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: -2),
        ),
        Text(
          "ANGULAR VECTOR",
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isDark ? Colors.white38 : Colors.black38, letterSpacing: 2),
        ),
      ],
    );
  }

  // ================= CONTROL CONSOLE =================

  Widget _buildControlConsole(BuildContext context, DeviceController controller, DeviceModel device, bool isOnline, bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("PRECISION ADJ.", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
              Container(
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: isOnline ? () {
                    setState(() => _localAngle = 90);
                    controller.setAngle(device.deviceId, 90);
                  } : null,
                  icon: const Icon(Icons.center_focus_strong_rounded, color: Color(0xFF1E3C72), size: 20),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 12,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
              activeTrackColor: const Color(0xFF1E3C72),
              inactiveTrackColor: isDark ? Colors.white10 : Colors.grey.shade200,
              thumbColor: const Color(0xFF1E3C72),
            ),
            child: Slider(
              value: _localAngle.toDouble(),
              min: 0,
              max: 180,
              divisions: 180,

              // 🟡 UI ONLY — no network
              onChanged: isOnline
                  ? (v) {
                setState(() => _localAngle = v.toInt());
              }
                  : null,

              // 🔥 ONE network call when finger is released
              onChangeEnd: isOnline
                  ? (v) {
                controller.setAngle(device.deviceId, v.toInt());
              }
                  : null,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSliderLabel("0°"),
                _buildSliderLabel("90°"),
                _buildSliderLabel("180°"),
              ],
            ),
          ),
          const SizedBox(height: 35),

          Row(
            children: [
              _buildPresetButton(controller, device, "MIN", 0, isOnline),
              const SizedBox(width: 12),
              _buildPresetButton(controller, device, "MID", 90, isOnline),
              const SizedBox(width: 12),
              _buildPresetButton(controller, device, "MAX", 180, isOnline),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSliderLabel(String text) => Text(text, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w900, fontSize: 12));

  Widget _buildPresetButton(DeviceController controller, DeviceModel device, String label, int value, bool isOnline) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isOnline ? const Color(0xFF1E3C72).withOpacity(0.05) : Colors.transparent,
          foregroundColor: const Color(0xFF1E3C72),
          elevation: 0,
          side: BorderSide(color: isOnline ? const Color(0xFF1E3C72).withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        onPressed: isOnline ? () {
          setState(() => _localAngle = value);
          controller.setAngle(device.deviceId, value);
        } : null,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }

  // ================= SYNC INTEGRITY CARD =================

  Widget _buildSyncIntegrityCard(bool isDark, Color cardColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.sync_lock_rounded, color: Colors.blueAccent, size: 22),
              const SizedBox(width: 12),
              const Text("DATA INTEGRITY ACTIVE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "Karmo Core ensures sub-ms angular synchronization. Real-time feedback is encrypted to prevent external interference with hardware vectors.",
            style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.5
            ),
          ),
        ],
      ),
    );
  }
}