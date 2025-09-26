import 'dart:ui';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../commonWidgets/custom_text_field.dart';
import '../commonWidgets/large_button.dart';
import '../commonWidgets/snackbar_utils.dart';
import '../services/login_service.dart';
import '../services/google_login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'dart:convert';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late AnimationController _imageController;
  late Animation<Offset> _floatingAnimation;

  late AnimationController _bgController;
  late Animation<double> _bgAnimation;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

    // Animated background
    _bgController =
    AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);

    _bgAnimation =
        Tween<double>(begin: -50, end: 50).animate(CurvedAnimation(
          parent: _bgController,
          curve: Curves.easeInOut,
        ));
  }

  @override
  void dispose() {
    _imageController.dispose();
    _bgController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ✅ Save user session
  Future<void> saveUserData(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();

    final user = response["user"];
    final userId = user["id"];
    final token = response["token"]; // 🔥 from login response

    await prefs.setInt("userId", userId);
    await prefs.setString("authToken", token); // 👈 better key name
    await prefs.setBool("isLoggedIn", true);

    debugPrint("✅ Saved userId: $userId");
    debugPrint("✅ Saved authToken: $token");
  }

  // ✅ Get userId
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId");
  }

  // ------------------- Google Sign-In Handler -------------------
  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) return;

      final GoogleSignInAuthentication googleAuth =
      await account.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        SnackbarUtils.showError(context, "Google Sign-In failed: Missing tokens");
        return;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final String? firebaseIdToken =
      await userCredential.user?.getIdToken();
      if (firebaseIdToken == null) {
        SnackbarUtils.showError(context, "Failed to get Firebase ID token");
        return;
      }

      final response = await GoogleAuthService().googleLogin(firebaseIdToken);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // ✅ Save correctly
        await saveUserData(body);

        SnackbarUtils.showSuccess(context, "Google login successful!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (response.statusCode == 400) {
        SnackbarUtils.showError(context, "Already registered with Google!");
      } else {
        SnackbarUtils.showError(
          context,
          "Google login failed (code: ${response.statusCode})",
        );
      }
    } catch (e) {
      SnackbarUtils.showError(context, "Error: $e");
    }
  }

  // ------------------- email  Handler -------------------

  Future<void> _handleEmailLogin() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final result = await LoginService.loginUser(email: email, password: password);

      if (result["success"]) {
        // ✅ Use top-level "user" and "token" from service response
        final userData = {
          "user": result["user"],
          "token": result["token"],
        };

        await saveUserData(userData);

        SnackbarUtils.showSuccess(context, "Login successful!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        SnackbarUtils.showError(context, result["message"] ?? "Login failed");
      }
    }
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

          // Floating Bot Image
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

          // Login UI
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
                            "Login",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Email Field
                          CustomTextField(
                            labelText: "Email",
                            controller: _emailController,
                            maxLength: 30,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              String trimmed = value?.trim() ?? '';
                              if (trimmed.isEmpty) return "Email can't be empty";
                              bool isEmailValid = EmailValidator.validate(trimmed);
                              bool isPhoneValid = RegExp(r'^\d{10}$').hasMatch(trimmed);
                              if (!isEmailValid && !isPhoneValid) return "Enter valid email or phone";
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          CustomTextField(
                            labelText: "Password",
                            controller: _passwordController,
                            isPassword: true,
                            maxLength: 10,
                            validator: (value) {
                              String trimmed = value?.trim() ?? '';
                              if (trimmed.isEmpty) return "Password can't be empty";

                              String pattern =
                                  r'^(?=.*[A-Za-z])(?=.*\d)(?=(?:.*[^A-Za-z0-9]){1})(?!.*[^A-Za-z0-9].*[^A-Za-z0-9]).{10}$';
                              if (!RegExp(pattern).hasMatch(trimmed)) {
                                return "Password must be 10 chars, include letters, numbers & exactly 1 special char";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const ForgotPasswordScreen()),
                                );
                              },
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Colors.purple.shade400,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Email/Password Login Button
                          LargeButton(
                            text: "Login",
                            onPressed: _handleEmailLogin,
                          ),
                          const SizedBox(height: 20),

                          // Register Link
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterScreen()),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have an account? ",
                                style: const TextStyle(color: Colors.black54, fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: "Create Account",
                                    style: TextStyle(
                                      color: Colors.purple.shade400,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Social Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _socialButton(
                                  "assets/images/facebook-removebg-preview.png", () {}),
                              const SizedBox(width: 20),
                              _socialButton(
                                  "assets/images/google-removebg-preview.png",
                                  _handleGoogleSignIn),
                              const SizedBox(width: 20),
                              _socialButton(
                                  "assets/images/apple-removebg-preview.png", () {}),
                            ],
                          )
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

  Widget _socialButton(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.white,
        child: Image.asset(assetPath, height: 24),
      ),
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
