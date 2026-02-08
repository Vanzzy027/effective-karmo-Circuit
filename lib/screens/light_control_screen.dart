import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/device_controller.dart';
import '../device_model.dart';

class LightControlScreen extends StatefulWidget {
  final DeviceModel device;

  const LightControlScreen({super.key, required this.device});

  @override
  State<LightControlScreen> createState() => _LightControlScreenState();
}

class _LightControlScreenState extends State<LightControlScreen> {
  late int _localAngle;

  @override
  void initState() {
    super.initState();
    _localAngle = widget.device.angle;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceController>(
      builder: (context, controller, _) {
        final device =
        controller.devices.isNotEmpty ? controller.devices.first : widget.device;

        // 🔥 Sync ONLY if device updated externally
        if (device.angle != _localAngle) {
          _localAngle = device.angle;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(device.name),
            backgroundColor:
            device.isConnected ? Colors.green : Colors.redAccent,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  device.isConnected ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                    device.isConnected ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                const Icon(Icons.lightbulb, size: 100, color: Colors.amber),
                const SizedBox(height: 24),
                Text(
                  'Angle: $_localAngle°',
                  style: const TextStyle(fontSize: 22),
                ),
                Slider(
                  value: _localAngle.toDouble(),
                  min: 0,
                  max: 180,
                  divisions: 180,
                  label: _localAngle.toString(),
                  onChanged: device.isConnected
                      ? (v) {
                    setState(() => _localAngle = v.toInt());
                    controller.setAngle(_localAngle);
                  }
                      : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Center (90°)'),
                  onPressed: device.isConnected
                      ? () {
                    setState(() => _localAngle = 90);
                    controller.setAngle(90);
                  }
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
