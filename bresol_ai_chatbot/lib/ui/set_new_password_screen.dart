import 'dart:ui';
import 'package:flutter/material.dart';
import '../commonWidgets/back_button.dart';
import '../commonWidgets/custom_text_field.dart';
import '../commonWidgets/large_button.dart';
import '../commonWidgets/snackbar_utils.dart';
import 'login_screen.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  late AnimationController _imageController;
  late Animation<Offset> _floatingAnimation;

  late AnimationController _bgController;
  late Animation<double> _bgAnimation;

  @override
  void initState() {
    super.initState();

    // Floating bot animation
    _imageController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _floatingAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: const Offset(0, -0.05),
    ).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeInOut),
    );

    // Glass background animation
    _bgController =
    AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);

    _bgAnimation = Tween<double>(begin: -50, end: 50).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _imageController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Confirm Password can't be empty";
    }
    if (value.trim() != _passwordController.text.trim()) {
      return "Passwords do not match";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Glassmorphic background
          AnimatedBuilder(
            animation: _bgAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: GlassBackgroundPainter(offset: _bgAnimation.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // Floating bot
          Positioned(
            top: screenHeight * 0.12,
            child: SlideTransition(
              position: _floatingAnimation,
              child: Image.asset(
                "assets/images/welcome2-removebg-preview.png",
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
          ),


          Positioned(
            top: 50,
            left: 20,
            child: AnimatedBackButton(
              iconColor: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Password UI
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Set New Password",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 25),

                          CustomTextField(
                            labelText: "Password",
                            controller: _passwordController,
                            isPassword: true,
                            maxLength: 10,
                            validator: (value) {
                              String trimmed = value?.trim() ?? '';
                              if (trimmed.isEmpty) {
                                return "Password can't be empty";
                              }
                              String pattern =
                                  r'^(?=.*[A-Za-z])(?=.*\d)(?=(?:.*[^A-Za-z0-9]){1})(?!.*[^A-Za-z0-9].*[^A-Za-z0-9]).{10}$';
                              if (!RegExp(pattern).hasMatch(trimmed)) {
                                return "Password must be 10 chars,\ninclude letters, numbers & exactly 1 special char";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          CustomTextField(
                            labelText: "Confirm Password",
                            controller: _confirmPasswordController,
                            isPassword: true,
                            maxLength: 10,
                            validator: _validateConfirmPassword,
                          ),
                          const SizedBox(height: 30),

                          LargeButton(
                            text: "Set Password",
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // ✅ Show animated success snackbar
                                SnackbarUtils.showSuccess(context, "Password reset successfully!");

                                // ✅ Navigate to LoginScreen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Glass background painter (same as other screens)
class GlassBackgroundPainter extends CustomPainter {
  final double offset;
  GlassBackgroundPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    paint.shader = LinearGradient(
      colors: [
        Colors.purple.withOpacity(0.2),
        Colors.blue.withOpacity(0.2),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path1 = Path()
      ..moveTo(0, size.height * 0.3 + offset)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.2 + offset,
          size.width, size.height * 0.4 + offset)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    Path path2 = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.8 + offset,
          size.width, size.height + offset)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant GlassBackgroundPainter oldDelegate) =>
      oldDelegate.offset != offset;
}
