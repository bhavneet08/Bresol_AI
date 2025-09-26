
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<double> _bgAnimation;

  late AnimationController _imageController;
  late Animation<Offset> _floatingAnimation;

  late AnimationController _greetingController;
  late Animation<double> _greetingFade;

  late AnimationController _quoteController;
  late Animation<double> _quoteFade;

  late AnimationController _containerGradientController;
  late AnimationController _chatImageController;
  late Animation<Offset> _chatImageFloating;

  String greeting = '';
  String quote = '';
  final List<String> quotes = [
    "Dream big, work hard.",
    "Stay hungry, stay foolish.",
    "Believe in yourself.",
    "Every moment is a fresh beginning.",
    "Success is not final, failure is not fatal."
  ];

  @override
  void initState() {
    super.initState();

    _setGreeting();
    _setRandomQuote();

    // Quote update every 15 sec with fade
    Timer.periodic(const Duration(seconds: 15), (timer) {
      _quoteController.reverse().then((_) {
        setState(() {
          _setRandomQuote();
        });
        _quoteController.forward();
      });
    });

    // Background animation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _bgAnimation = Tween<double>(begin: -50, end: 50).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );

    // Floating bot image animation
    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: const Offset(0, -0.05),
    ).animate(CurvedAnimation(parent: _imageController, curve: Curves.easeInOut));

    // Floating chat image animation
    _chatImageController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _chatImageFloating = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: const Offset(0, -0.05),
    ).animate(CurvedAnimation(parent: _chatImageController, curve: Curves.easeInOut));

    // Greeting fade animation
    _greetingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _greetingFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _greetingController, curve: Curves.easeIn),
    );
    _greetingController.forward();

    // Quote fade animation
    _quoteController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _quoteFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _quoteController, curve: Curves.easeIn),
    );
    _quoteController.forward();

    // Container gradient animation
    _containerGradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 18) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }
  }

  void _setRandomQuote() {
    final random = Random();
    quote = quotes[random.nextInt(quotes.length)];
  }

  @override
  void dispose() {
    _bgController.dispose();
    _imageController.dispose();
    _chatImageController.dispose();
    _greetingController.dispose();
    _quoteController.dispose();
    _containerGradientController.dispose();
    super.dispose();
  }

  LinearGradient animatedGradient(double offset) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.pink.shade100.withOpacity(0.6 + offset * 0.1),
        Colors.blue.shade100.withOpacity(0.6 + offset * 0.1),
        Colors.green.shade100.withOpacity(0.6 + offset * 0.1),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Animated background
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

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 250),

                  // Greeting container
                  AnimatedBuilder(
                    animation: _containerGradientController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _greetingFade,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: animatedGradient(_containerGradientController.value),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Text(
                            greeting,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Quote container
                  AnimatedBuilder(
                    animation: _containerGradientController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _quoteFade,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: animatedGradient(1 - _containerGradientController.value),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Text(
                            '"$quote"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // Chat image container with floating animation
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _containerGradientController,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: animatedGradient(
                                  (_containerGradientController.value + 0.5) % 1),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: SlideTransition(
                              position: _chatImageFloating,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/chat-message.png",
                                    height: 100,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Start chatting with Bresol AI!',
                                    style: TextStyle(color: Colors.black54, fontSize: 22),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
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
          size.width, size.height * 0.6 + offset)
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
