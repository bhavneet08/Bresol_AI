
import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';

import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _botController;

  @override
  void initState() {
    super.initState();

    // Bot floating animation
    _botController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _botController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Dynamic sizing
    double botHeight = screenHeight * 0.28;
    double textSize = screenWidth * 0.08;
    double smallTextSize = screenWidth * 0.045;

    final botAnimation =
    Tween<Offset>(begin: const Offset(0, 0.05), end: const Offset(0, -0.05))
        .animate(CurvedAnimation(
      parent: _botController,
      curve: Curves.easeInOut,
    ));

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF), // White
              Color(0xFFD9D9D9), // Silver Grey
              Color(0xFFADD8E6), // Light Blue
              Color(0xFFBBBBEC), // Light Lavender
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.1, 0.3, 0.7, 1.0], // ensures all 4 colors are visible
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.08),

            // Title
            Text(
              "Make It\nAwesome",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),

            SizedBox(height: screenHeight * 0.05),

            // Floating Bot
            SlideTransition(
              position: botAnimation,
              child: Image.asset(
                "assets/images/welcome2-removebg-preview.png", // replace with bot image
                height: botHeight,
              ),
            ),

            SizedBox(height: screenHeight * 0.04),

            // Version Chip

            SizedBox(height: screenHeight * 0.02),

            // Subtitle
            Text(
              "Welcome to Bresol\n Let AI be your guide.",
              style: TextStyle(
                fontSize: smallTextSize,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // Get Started Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: SlideAction(
                text: "Get Started",
                textStyle: TextStyle(
                  fontSize: smallTextSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                outerColor: Color(0xFFE6E6FA), // Lavender
                innerColor: Colors.white, // Slider button color
                sliderButtonIcon: Icon(
                  Icons.arrow_forward,
                  color: Color(0xFFE6E6FA), // Lavender arrow
                  size: screenWidth * 0.07,
                ),
                borderRadius: 30,
                elevation: 6,
                onSubmit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(), // your login screen
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}