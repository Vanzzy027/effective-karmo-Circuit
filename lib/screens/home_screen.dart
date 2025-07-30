import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:karmo/screens/light_control_screen.dart' as screen;
import 'package:karmo/widgets/bulb_slider_card.dart' as widget;
import '../screens/profile_screen.dart';
import 'package:karmo/utils/ble_manager.dart';

class HomeScreen extends StatefulWidget {
  final String? username;

  const HomeScreen({super.key, this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BleManager ble = BleManager();
  List<int> bulbStates = List<int>.filled(4, 0);
  PageController pageController = PageController();
  String username = 'Guest';
  StreamSubscription<String>? bleSubscription;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _initBLE();
  }

  @override
  void dispose() {
    bleSubscription?.cancel();
    pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('loggedInUser') ?? 'Guest';
    });
  }

  Future<void> _initBLE() async {
    bool success = await ble.connectToKarmo();
    if (success) {
      ble.requestStatusAll();
      bleSubscription = ble.onStatusUpdate().listen((data) {
        if (data.startsWith("STATUS:")) {
          final parts = data.replaceAll("\n", "").split(":");
          if (parts.length >= 3) {
            int id = int.parse(parts[1]);
            int value = int.parse(parts[2]);
            if (id >= 1 && id <= bulbStates.length) {
              setState(() {
                bulbStates[id - 1] = value;
              });
            }
          }
        }
      });
    }
  }

  void onSliderChange(int bulbID, int newValue) async {
    setState(() => bulbStates[bulbID - 1] = newValue);
    ble.sendBrightness(bulbID, newValue);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bulb_$bulbID', newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome, $username"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(username: username),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: bulbStates.length,
              itemBuilder: (context, index) {
                return widget.BulbSliderCard(
                  bulbId: index + 1,
                  brightness: bulbStates[index],
                  onChanged: (val) => onSliderChange(index + 1, val.toInt()),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                colors: [Color(0xFF6A5ACD), Color(0xFF00BFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => screen.LightControlScreen(),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lightbulb_outline, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Control Lights',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
