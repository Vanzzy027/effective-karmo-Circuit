import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/device_controller.dart';
import '../screens/light_control_screen.dart';
import '../auth/register_screen.dart';
import '../device_model.dart';

class HomeScreen extends StatelessWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final c = DeviceController();
        c.init();
        return c;
      },
      child: Consumer<DeviceController>(
        builder: (context, controller, _) {
          final DeviceModel? device =
          controller.devices.isNotEmpty ? controller.devices.first : null;

          return Scaffold(
            appBar: AppBar(
              title: const Text("Karmo"),
              actions: [
                if (controller.isScanning)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: "Reconnect",
                    onPressed: controller.discoverDevice,
                  ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                          (_) => false,
                    );
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(username, controller),
                    const SizedBox(height: 24),
                    _buildHeroCard(context, device),
                    const SizedBox(height: 24),
                    Text(
                      "Devices",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: device == null
                          ? const Center(child: Text("No devices found"))
                          : _buildDeviceTile(context, device),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader(String username, DeviceController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome back"),
            Text(
              username,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: controller.isConnected
                ? Colors.green.withValues(alpha: 0.15)
                : Colors.red.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: controller.isConnected ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 6),
              Text(
                controller.isConnected ? "Online" : "Offline",
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= HERO CARD =================

  Widget _buildHeroCard(BuildContext context, DeviceModel? device) {
    return GestureDetector(
      onTap: device != null && device.isConnected
          ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LightControlScreen(device: device),
          ),
        );
      }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1E3C72),
              Color(0xFF2A5298),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lightbulb, color: Colors.amber, size: 40),
            const SizedBox(height: 16),
            Text(
              device?.name ?? "No Device",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              device != null ? "Angle: ${device.angle}°" : "Offline",
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DEVICE TILE =================

  Widget _buildDeviceTile(BuildContext context, DeviceModel device) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(
          Icons.lightbulb_outline,
          color: device.isConnected ? Colors.amber : Colors.grey,
        ),
        title: Text(device.name),
        subtitle: Text("Angle: ${device.angle}°"),
        trailing: const Icon(Icons.chevron_right),
        onTap: device.isConnected
            ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LightControlScreen(device: device),
            ),
          );
        }
            : null,
      ),
    );
  }
}
