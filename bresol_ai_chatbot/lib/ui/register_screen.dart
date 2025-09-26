import 'dart:ui';
import 'package:flutter/material.dart';

import '../commonWidgets/back_button.dart';
import '../commonWidgets/custom_text_field.dart';
import '../commonWidgets/large_button.dart';
import '../commonWidgets/snackbar_utils.dart'; // ✅ Import SnackbarUtils
import '../services/register_service.dart';
import 'otpVerification_Screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<double> _bgAnimation;

  late AnimationController _imageController;
  late Animation<Offset> _floatingAnimation;

  final _fullNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  int _contactMaxLength = 30;

  @override
  void initState() {
    super.initState();

    _bgController =
    AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    _bgAnimation = Tween<double>(begin: -50, end: 50).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );

    _imageController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _floatingAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: const Offset(0, -0.05),
    ).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeInOut),
    );

    _contactController.addListener(_updateContactMaxLength);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _imageController.dispose();
    _fullNameController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateContactMaxLength() {
    final text = _contactController.text.trim();
    if (RegExp(r'^[0-9]+$').hasMatch(text)) {
      if (_contactMaxLength != 10) setState(() => _contactMaxLength = 10);
    } else {
      if (_contactMaxLength != 30) setState(() => _contactMaxLength = 30);
    }
  }

  String? _validateContact(String? value) {
    if (value == null || value.isEmpty) return "Contact is required";
    final trimmed = value.trim();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!emailRegex.hasMatch(trimmed) && !phoneRegex.hasMatch(trimmed)) {
      return "Enter a valid email or 10-digit phone number";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return "Confirm your password";
    if (value != _passwordController.text) return "Passwords do not match";
    return null;
  }

  bool _isEmail(String contact) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(contact.trim());
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          AnimatedBuilder(
            animation: _bgAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: GlassBackgroundPainter(offset: _bgAnimation.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),
          Positioned(
            top: screenHeight * 0.1,
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
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Create Account",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              labelText: "Full Name",
                              controller: _fullNameController,
                              maxLength: 30,
                              validator: (value) =>
                              value == null || value.isEmpty
                                  ? "Full name is required"
                                  : null,
                            ),
                            const SizedBox(height: 15),
                            CustomTextField(
                              labelText: "Email or Mobile Number",
                              controller: _contactController,
                              keyboardType: TextInputType.text,
                              maxLength: _contactMaxLength,
                              validator: _validateContact,
                            ),
                            const SizedBox(height: 15),
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
                            const SizedBox(height: 15),
                            CustomTextField(
                              labelText: "Confirm Password",
                              controller: _confirmPasswordController,
                              isPassword: true,
                              maxLength: 10,
                              validator: _validateConfirmPassword,
                            ),
                            const SizedBox(height: 25),
                            // LargeButton(
                            //   text: "Register",
                            //   onPressed: () {
                            //     if (_formKey.currentState!.validate()) {
                            //       String contact =
                            //       _contactController.text.trim();
                            //
                            //       // ✅ Show snackbar based on email or phone
                            //       if (_isEmail(contact)) {
                            //         SnackbarUtils.showInfo(
                            //             context, "OTP sent on your email 📧");
                            //       } else {
                            //         SnackbarUtils.showInfo(
                            //             context, "OTP sent on your mobile number 📱");
                            //       }
                            //
                            //       Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //           builder: (context) =>
                            //               OtpVerificationScreen(contact: contact),
                            //         ),
                            //       );
                            //     }
                            //   },
                            // ),
                            // LargeButton(
                            //   text: "Register",
                            //   onPressed: () async {
                            //     if (_formKey.currentState!.validate()) {
                            //       String fullName = _fullNameController.text.trim();
                            //       String contact = _contactController.text.trim();
                            //       String password = _passwordController.text.trim();
                            //
                            //       // ✅ Call API
                            //       final response = await RegisterService.registerUser(
                            //         fullName: fullName,
                            //         contact: contact,
                            //         password: password,
                            //       );
                            //
                            //       if (response["success"] == true) {
                            //         SnackbarUtils.showSuccess(context, "OTP sent successfully ✅");
                            //
                            //         Navigator.push(
                            //           context,
                            //           MaterialPageRoute(
                            //             builder: (context) => OtpVerificationScreen(contact: contact),
                            //           ),
                            //         );
                            //       } else {
                            //         SnackbarUtils.showError(context, response["message"]);
                            //       }
                            //     }
                            //   },
                            // ),
                            // LargeButton(
                            //   text: "Register",
                            //   onPressed: () async {
                            //     if (_formKey.currentState!.validate()) {
                            //       String fullName = _fullNameController.text.trim();
                            //       String contact = _contactController.text.trim();
                            //       String password = _passwordController.text.trim();
                            //
                            //       // ✅ Call API
                            //       final response = await RegisterService.registerUser(
                            //         email: _contactController.text.trim(),
                            //         password: _passwordController.text.trim(),
                            //       );
                            //
                            //
                            //       if (response["success"] == true) {
                            //         SnackbarUtils.showSuccess(context, "OTP sent successfully ✅");
                            //
                            //         Navigator.push(
                            //           context,
                            //           MaterialPageRoute(
                            //             builder: (context) => OtpVerificationScreen(contact: contact),
                            //           ),
                            //         );
                            //       } else {
                            //         // 🔴 Show snackbar to user
                            //         SnackbarUtils.showError(context, response["message"]);
                            //
                            //         // 🖥️ Print full error details in terminal
                            //         debugPrint("❌ Registration Error: ${response["message"]}");
                            //       }
                            //     }
                            //   },
                            // ),



                            // LargeButton(
                            //   text: "Register",
                            //   onPressed: () async {
                            //     if (_formKey.currentState!.validate()) {
                            //       String username = _fullNameController.text.trim();
                            //       String email = _contactController.text.trim();
                            //       String password = _passwordController.text.trim();
                            //
                            //       // ✅ Call API
                            //       final response = await RegisterService.registerUser(
                            //         username: username,
                            //         email: email,
                            //         password: password,
                            //       );
                            //
                            //       if (response["success"] == true) {
                            //         // 🔹 Show success message
                            //         SnackbarUtils.showSuccess(context, response["message"] ?? "OTP sent successfully ✅");
                            //
                            //         // 🔹 Navigate to OTP verification screen, passing temp_user_id or contact
                            //         Navigator.push(
                            //           context,
                            //           MaterialPageRoute(
                            //             builder: (context) => OtpVerificationScreen(
                            //               contact: email,
                            //               tempUserId: response["temp_user_id"], // pass temp_user_id if needed
                            //             ),
                            //           ),
                            //         );
                            //       } else {
                            //         // 🔴 Show error snackbar
                            //         SnackbarUtils.showError(context, response["message"] ?? "Registration failed");
                            //
                            //         // 🖥️ Print full error details in terminal
                            //         debugPrint("❌ Registration Error: ${response["message"]}");
                            //       }
                            //     }
                            //   },
                            // ),


                            LargeButton(
                              text: "Register",
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  String username = _fullNameController.text.trim();
                                  String email = _contactController.text.trim();
                                  String password = _passwordController.text.trim();

                                  // ✅ Call API
                                  final response = await RegisterService.registerUser(
                                    username: username,
                                    email: email,
                                    password: password,
                                  );

                                  if (response["success"] == true) {
                                    // 🔹 Show success message
                                    SnackbarUtils.showSuccess(
                                      context,
                                      response["message"] ?? "OTP sent successfully ✅",
                                    );

                                    // 🔹 Navigate to OTP verification screen, passing contact & temp_user_id
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OtpVerificationScreen(
                                          contact: email,
                                          tempUserId: response["temp_user_id"], // <-- backend sends this
                                        ),
                                      ),
                                    );
                                  } else {
                                    // 🔴 Show error snackbar
                                    SnackbarUtils.showError(
                                      context,
                                      response["message"] ?? "Registration failed",
                                    );

                                    // 🖥️ Debug print
                                    debugPrint("❌ Registration Error: ${response["message"]}");
                                  }
                                }
                              },
                            ),




                            const SizedBox(height: 15),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: RichText(
                                text: TextSpan(
                                  text: "Already have an account? ",
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Login",
                                      style: TextStyle(
                                        color: Colors.purple.shade400,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     _socialButton(
                            //         "assets/images/facebook-removebg-preview.png"),
                            //     const SizedBox(width: 20),
                            //     _socialButton(
                            //         "assets/images/google-removebg-preview.png"),
                            //     const SizedBox(width: 20),
                            //     _socialButton(
                            //         "assets/images/apple-removebg-preview.png"),
                            //   ],
                            // )
                          ],
                        ),
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

  Widget _socialButton(String assetPath) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.white,
      child: Image.asset(assetPath, height: 24),
    );
  }
}

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
