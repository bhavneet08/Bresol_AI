import 'dart:ui';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import '../commonWidgets/custom_text_field.dart';
import '../commonWidgets/large_button.dart';
import '../commonWidgets/back_button.dart'; // Import the animated back button
import '../commonWidgets/snackbar_utils.dart'; // Import Snackbar utils
import 'forgot_otpVerification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  late AnimationController _imageController;
  late Animation<Offset> _floatingAnimation;

  late AnimationController _bgController;
  late Animation<double> _bgAnimation;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  // Mock database check
  bool _userExists(String input) {
    // Example: assume users exist if email contains "user" or phone starts with "9"
    final isEmail = EmailValidator.validate(input);
    final isPhone = RegExp(r'^\d{10}$').hasMatch(input);
    if ((isEmail && input.contains("user")) || (isPhone && input.startsWith("9"))) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    // Floating bot image animation
    _imageController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _floatingAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: const Offset(0, -0.05),
    ).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeInOut),
    );

    // Background animation
    _bgController =
    AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);

    _bgAnimation = Tween<double>(begin: -50, end: 50).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _imageController.dispose();
    _bgController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (!_formKey.currentState!.validate()) return;

    final input = _emailController.text.trim();
    final isEmail = EmailValidator.validate(input);
    final isPhone = RegExp(r'^\d{10}$').hasMatch(input);

    if (!_userExists(input)) {
      SnackbarUtils.showError(context, "User does not exist ❌");
      return;
    }

    if (isEmail) {
      SnackbarUtils.showInfo(context, "OTP sent on your email ✉️");
    } else if (isPhone) {
      SnackbarUtils.showInfo(context, "OTP sent on your mobile number 📱");
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForgotOtpVerificationScreen(userInput: input),
      ),
    );
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

          // Floating bot image
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

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: AnimatedBackButton(
              iconColor: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Forgot Password UI
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
                            "Forgot Password",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 25),

                          CustomTextField(
                            labelText: "Enter your Email or Phone",
                            controller: _emailController,
                            maxLength: 30,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              String trimmed = value?.trim() ?? '';
                              if (trimmed.isEmpty) {
                                return "Email/Phone can't be empty";
                              }
                              bool isEmailValid = EmailValidator.validate(trimmed);
                              bool isPhoneValid =
                              RegExp(r'^\d{10}$').hasMatch(trimmed);

                              if (!isEmailValid && !isPhoneValid) {
                                return "Enter a valid email or phone";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25),

                          LargeButton(
                            text: "Reset Password",
                            onPressed: _handleResetPassword,
                          ),

                          const SizedBox(height: 20),
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

// Glass background painter
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
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.2 + offset, size.width, size.height * 0.4 + offset)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    Path path2 = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.8 + offset, size.width, size.height + offset)
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
