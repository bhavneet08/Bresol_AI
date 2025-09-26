
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../commonWidgets/back_button.dart';
import '../commonWidgets/snackbar_utils.dart';
import '../services/otpVerification_service.dart';
import '../services/resend_otp_service.dart';
import 'RegistrationSuccess_Screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String contact; // email or phone
  final int tempUserId; // temp_user_id from registration

  const OtpVerificationScreen({
    super.key,
    required this.contact,
    required this.tempUserId,
  });

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with TickerProviderStateMixin {
  late AnimationController _imageController;
  late Animation<Offset> _floatingAnimation;
  late AnimationController _bgController;
  late Animation<double> _bgAnimation;

  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 5; // OTP valid for 5 seconds
  bool _canResend = false;

  @override
  void initState() {
    super.initState();

    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: const Offset(0, -0.05),
    ).animate(CurvedAnimation(parent: _imageController, curve: Curves.easeInOut));

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _bgAnimation = Tween<double>(begin: -50, end: 50)
        .animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _remainingSeconds = 5;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 4) {
      SnackbarUtils.showError(context, "Enter valid 4 digit OTP ❌");
      return;
    }

    final response = await VerifyOtpService.verifyOtp(
      tempUserId: widget.tempUserId,
      otp: _otpController.text.trim(),
    );

    if (response["success"] == true || response["token"] != null) {
      SnackbarUtils.showSuccess(context, "OTP Verified ✅");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const RegistrationSuccessScreen(),
        ),
      );
    } else {
      SnackbarUtils.showError(context, response["message"]);
    }
  }

  void _resendOtp() async {
    final response = await ResendOtpService.resendOtp(email: widget.contact);

    if (response["success"] == true) {
      SnackbarUtils.showSuccess(context, response["message"]);
      _startTimer(); // restart countdown
    } else {
      SnackbarUtils.showError(context, response["message"]);
    }
  }


  @override
  void dispose() {
    _imageController.dispose();
    _bgController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Verify Email / Phone",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Enter the 4 digit code sent to ${widget.contact}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 25),
                        PinCodeTextField(
                          appContext: context,
                          length: 4,
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          animationType: AnimationType.fade,
                          cursorColor: Colors.black,
                          animationDuration: const Duration(milliseconds: 300),
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(8),
                            fieldHeight: 50,
                            fieldWidth: 45,
                            activeFillColor: Colors.white,
                            selectedFillColor: Colors.white,
                            inactiveFillColor: Colors.white,
                            activeColor: Colors.purple,
                            selectedColor: Colors.blue,
                            inactiveColor: Colors.grey,
                          ),
                          enableActiveFill: true,
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 15),
                        _canResend
                            ? GestureDetector(
                          onTap: _resendOtp,
                          child: const Text(
                            "Resend Code",
                            style: TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                            : Text(
                          "Code expires in $_remainingSeconds s",
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _verifyOtp,
                          child: const Text(
                            "Verify OTP",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        )
                      ],
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

class GlassBackgroundPainter extends CustomPainter {
  final double offset;
  GlassBackgroundPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    paint.shader = LinearGradient(
      colors: [Colors.purple.withOpacity(0.2), Colors.blue.withOpacity(0.2)],
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
