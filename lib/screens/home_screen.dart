import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/device_controller.dart';
import '../screens/light_control_screen.dart';
import '../auth/register_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _lastDeviceCount = 0;


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121416) : const Color(0xFFF8F9FA);
    final accentColor = const Color(0xFF1E3C72);
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Consumer<DeviceController>(
      builder: (context, controller, _) {
        if (controller.devices.length > _lastDeviceCount) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showStyledSnackBar(context, "✨ Hardware Synchronized", isDark);
          });
          _lastDeviceCount = controller.devices.length;
        }

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            toolbarHeight: 0,
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => controller.scanNetwork(),
              color: accentColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    // User Header now contains the buttons flexed to the right
                    _buildUserHeader(widget.username, isDark, controller),

                    const SizedBox(height: 30),
                    _buildHeroConnectivityCard(context, controller, isDark),
                    const SizedBox(height: 25),
                    _buildSystemOverview(controller, context, isDark),
                    const SizedBox(height: 35),
                    _buildSectionHeader(context, "Active Peripherals", "SCANNING", isDark),
                    const SizedBox(height: 15),
                    _buildDeviceGrid(controller, context, surfaceColor, isDark),
                    const SizedBox(height: 30),
                    _buildEcosystemInsights(context, isDark),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= INTEGRATED USER HEADER & CONTROLS =================

  Widget _buildUserHeader(String username, bool isDark, DeviceController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Side: Greeting
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "KARMO CONTROL INTERFACE",
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Hello, $username",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),

        // Right Side: Action Buttons (Flexed)
        Row(
          children: [
            _buildCircleAction(
              icon: controller.isScanning ? Icons.sync : Icons.refresh_rounded,
              onPressed: () => controller.scanNetwork(),
              isLoading: controller.isScanning,
              isDark: isDark,
            ),
            const SizedBox(width: 12),
            _buildCircleAction(
              icon: Icons.power_settings_new_rounded,
              color: Colors.redAccent.withOpacity(0.1),
              iconColor: Colors.redAccent,
              onPressed: () => _handleLogout(context),
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  // ================= MODERN HERO COMPONENT =================

  Widget _buildHeroConnectivityCard(BuildContext context, DeviceController controller, bool isDark) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1214), Color(0xFF1E3C72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3C72).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.hub_outlined, size: 200, color: Colors.white.withOpacity(0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wifi_tethering, color: Colors.greenAccent, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "HUB NETWORK ACTIVE",
                            style: TextStyle(
                              color: Colors.greenAccent.withOpacity(0.8),
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Synchronized\nEnvironment",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.settings_input_component_rounded, color: Colors.white, size: 40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= SYSTEM OVERVIEW =================

  Widget _buildSystemOverview(DeviceController controller, BuildContext context, bool isDark) {
    final online = controller.devices.where((d) => d.isConnected).length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStat("Nodes", controller.devices.length.toString(), isDark),
          _buildStat("Live", online.toString(), isDark),
          _buildStat("Latency", online > 0 ? "2ms" : "---", isDark),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  // ================= DEVICE GRID =================

  Widget _buildDeviceGrid(DeviceController controller, BuildContext context, Color surface, bool isDark) {
    if (controller.devices.isEmpty) return _buildEmptyState(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.0,
      ),
      itemCount: controller.devices.length,
      itemBuilder: (context, index) {
        final device = controller.devices[index];
        final bool isOnline = device.isConnected;

        return GestureDetector(
          onTap: isOnline ? () => _navigateToControl(context, device.deviceId) : null,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isOnline ? const Color(0xFF1E3C72).withOpacity(0.2) : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: isOnline ? Colors.amber.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  child: Icon(Icons.settings_remote_rounded, color: isOnline ? Colors.amber : Colors.grey, size: 20),
                ),
                const Spacer(),
                Text(
                  device.name,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isOnline ? "OPERATIONAL" : "OFFLINE",
                  style: TextStyle(
                    color: isOnline ? Colors.blueAccent : Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= INSIGHTS =================

  Widget _buildEcosystemInsights(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "DATA INTEGRITY",
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blue.shade800, fontSize: 11, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            "Hardware synchronization is performed over a secured local bridge. Karmo optimizes motor response to prevent angular drift during high-load operations.",
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  Widget _buildCircleAction({required IconData icon, required VoidCallback onPressed, Color? color, Color? iconColor, bool isLoading = false, required bool isDark}) {
    return Container(
      height: 48,
      width: 48,
      decoration: BoxDecoration(
        color: color ?? (isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: isLoading
          ? const Padding(padding: EdgeInsets.all(14), child: CircularProgressIndicator(strokeWidth: 2.5))
          : IconButton(
        icon: Icon(icon, size: 22, color: iconColor ?? (isDark ? Colors.white : Colors.black87)),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String action, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            action,
            style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.developer_board_off_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 20),
          const Text("EMPTY HUB", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showStyledSnackBar(BuildContext context, String message, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w900)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? Colors.blueGrey.shade900 : const Color(0xFF1E3C72),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _navigateToControl(BuildContext context, String deviceId) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => LightControlScreen(deviceId: deviceId)));
  }

  void _handleLogout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
          (_) => false,
    );
  }
}


