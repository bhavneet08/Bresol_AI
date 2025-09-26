import 'package:bresol_ai_chatbot/ui/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'chat_bot_screen.dart'; // ✅ Import new chatbot screen
import 'setting_screen.dart';
import '../Menu/sidedrown_menu.dart';
import 'home.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const Home(),
      const ChatBotScreen(), // ✅ Replaced with new screen
      // const Center(child: Text("🔔 Notifications", style: TextStyle(fontSize: 24))),
      const ProfileScreen(),
      const SettingScreen(),
    ];

    // return Scaffold(
    //   extendBody: true,
    //   body: pages[_currentIndex],
    //   bottomNavigationBar: _buildGlassNavBar(),
    // );
    return Scaffold(
      extendBody: true,
      drawer: const SideDrownMenu(),
      body: Stack(
        children: [
          pages[_currentIndex], // your main page content

          // Floating menu button
          Positioned(
            top: 40, // adjust as needed
            left: 16, // adjust as needed
            child: Builder(
              builder: (context) => FloatingActionButton(
                mini: true,
                backgroundColor: Colors.deepPurple[200],
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Icon(Icons.menu),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildGlassNavBar(),
    );

  }

  Widget _buildGlassNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white.withOpacity(0.1), // optional glass effect
      elevation: 0,
      selectedItemColor: Colors.deepPurple, // ✅ selected icon & label color
      unselectedItemColor: Colors.grey.shade600, // ✅ unselected color
      showUnselectedLabels: true, // show labels for all items
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.smart_toy),
          label: "AI Bot",
        ),
        // BottomNavigationBarItem(
        //   icon: badges.Badge(
        //     badgeContent: const Text(
        //       "5",
        //       style: TextStyle(
        //         color: Colors.white, // ✅ text inside badge
        //         fontSize: 10,
        //       ),
        //     ),
        //     badgeStyle: const badges.BadgeStyle(
        //       badgeColor: Colors.deepPurple, // ✅ badge background color
        //     ),
        //     child: const Icon(Icons.notifications),
        //   ),
        //   label: "Alerts",
        // ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Settings",
        ),
      ],
    );
  }
}
