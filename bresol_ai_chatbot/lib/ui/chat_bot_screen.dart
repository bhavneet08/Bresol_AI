
// import 'dart:math';
// import 'dart:ui';
// import 'package:bresol_ai_chatbot/helper/constant.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import '../services/api_service.dart' as api; // <-- prefix added
//
// class GlassBackgroundPainter extends CustomPainter {
//   final double offset;
//   GlassBackgroundPainter({required this.offset});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()..style = PaintingStyle.fill;
//     paint.shader = LinearGradient(
//       colors: [Colors.purple.withOpacity(0.2), Colors.blue.withOpacity(0.2)],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
//
//     Path path1 = Path()
//       ..moveTo(0, size.height * 0.3 + offset)
//       ..quadraticBezierTo(size.width * 0.5, size.height * 0.2 + offset,
//           size.width, size.height * 0.4 + offset)
//       ..lineTo(size.width, 0)
//       ..lineTo(0, 0)
//       ..close();
//
//     Path path2 = Path()
//       ..moveTo(0, size.height)
//       ..quadraticBezierTo(size.width * 0.5, size.height * 0.8 + offset,
//           size.width, size.height + offset)
//       ..lineTo(size.width, size.height)
//       ..lineTo(0, size.height)
//       ..close();
//
//     canvas.drawPath(path1, paint);
//     canvas.drawPath(path2, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant GlassBackgroundPainter oldDelegate) =>
//       oldDelegate.offset != offset;
// }
//
// class CircleWavePainter extends CustomPainter {
//   final double progress;
//   CircleWavePainter(this.progress);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2.2;
//     final dotCount = 40;
//
//     for (int i = 0; i < dotCount; i++) {
//       final angle = (2 * pi / dotCount) * i + progress;
//       final dx = center.dx + radius * cos(angle);
//       final dy = center.dy + radius * sin(angle);
//
//       final paint = Paint()
//         ..color = Colors.deepPurple
//             .withOpacity(0.6 + 0.4 * sin(angle + progress))
//         ..style = PaintingStyle.fill;
//
//       canvas.drawCircle(Offset(dx, dy), 4, paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(CircleWavePainter oldDelegate) => true;
// }
//
// class ChatBotScreen extends StatefulWidget {
//   const ChatBotScreen({super.key});
//
//   @override
//   State<ChatBotScreen> createState() => _ChatBotScreenState();
// }
//
// class _ChatBotScreenState extends State<ChatBotScreen>
//     with TickerProviderStateMixin {
//   List<Map<String, String>> _messages = [];
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//
//   late GenerativeModel _model;
//   late AnimationController _bgController;
//   late AnimationController _circleController;
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//
//   final ImagePicker _picker = ImagePicker();
//
//   api.ChatSession? _currentSession; // <-- use prefixed class
//
//   @override
//   void initState() {
//     super.initState();
//
//     _model = GenerativeModel(model: "gemini-1.5-flash", apiKey: apiKey);
//
//     _bgController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 5),
//     )..repeat(reverse: true);
//
//     _circleController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 6),
//     )..repeat();
//
//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);
//
//     _fadeAnimation =
//         Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
//           parent: _fadeController,
//           curve: Curves.easeInOut,
//         ));
//
//     _loadChatHistory();
//   }
//
//   @override
//   void dispose() {
//     _bgController.dispose();
//     _circleController.dispose();
//     _fadeController.dispose();
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadChatHistory() async {
//     List<api.ChatSession> history = await api.ApiService.getChatHistory(limit: 1);
//     if (history.isNotEmpty) {
//       _currentSession = history.first;
//       setState(() {
//         _messages = _currentSession!.messages
//             .map((msg) => {
//           "sender": msg['sender'].toString(),
//           "text": msg['text'].toString()
//         })
//             .toList();
//       });
//       await Future.delayed(const Duration(milliseconds: 50));
//       _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//     } else {
//       _currentSession = api.ChatSession(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         title: "Chat with AI",
//         createdAt: DateTime.now(),
//         messages: [],
//       );
//     }
//   }
//
//   Future<void> _saveChatHistory() async {
//     if (_currentSession == null) return;
// print("1");
//     _currentSession!.messages = _messages
//         .map((msg) => {"role": msg['sender'], "text": msg['text']})
//         .toList();
//
//     print("2 : ${_currentSession!.messages}");
//     await api.ApiService.saveChatHistory([_currentSession!]);
//   }
//
//   Future<void> _openCamera() async {
//     final pickedFile =
//     await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
//     if (pickedFile != null) {
//       debugPrint("Camera image: ${pickedFile.path}");
//     }
//   }
//
//   Future<void> _openGallery() async {
//     final pickedFile =
//     await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
//     if (pickedFile != null) {
//       debugPrint("Gallery image: ${pickedFile.path}");
//     }
//   }
//
//   Future<void> _openFileManager() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       debugPrint("Picked file: ${result.files.single.path}");
//     }
//   }
//
//   void _sendMessage() async {
//     if (_messageController.text.isEmpty) return;
//
//     String userInput = _messageController.text;
//     setState(() {
//       _messages.add({"sender": "user", "text": userInput});
//     });
//     _messageController.clear();
//     _scrollToBottom();
//
//     try {
//       final response = await _model.generateContent([Content.text(userInput)]);
//       setState(() {
//         _messages.add({
//           "sender": "bot",
//           "text": response.text ?? "⚠️ No response from Gemini"
//         });
//       });
//       _scrollToBottom();
//       await _saveChatHistory();
//     } catch (e) {
//       setState(() {
//         _messages.add({"sender": "bot", "text": "⚠️ Error: $e"});
//       });
//     }
//   }
//
//   void _scrollToBottom() async {
//     await Future.delayed(const Duration(milliseconds: 50));
//     _scrollController.animateTo(
//       _scrollController.position.maxScrollExtent,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//     );
//   }
//
//   Widget _glassIcon(IconData icon) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(30),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           height: 56,
//           width: 56,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: Colors.white),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: Listenable.merge([_bgController, _circleController, _fadeController]),
//       builder: (context, _) {
//         return Scaffold(
//           body: CustomPaint(
//             painter: GlassBackgroundPainter(offset: _bgController.value * 20),
//             child: SafeArea(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),
//                   CustomPaint(
//                     painter: CircleWavePainter(_circleController.value * 2 * pi),
//                     child: Container(
//                       width: 200,
//                       height: 200,
//                       alignment: Alignment.center,
//                       child: FadeTransition(
//                         opacity: _fadeAnimation,
//                         child: const Text(
//                           "Hi, can I help you?",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.deepPurple,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Expanded(
//                     child: ListView.builder(
//                       controller: _scrollController,
//                       padding: const EdgeInsets.all(16),
//                       itemCount: _messages.length,
//                       itemBuilder: (context, index) {
//                         final msg = _messages[index];
//                         final isUser = msg['sender'] == 'user';
//
//                         return Align(
//                           alignment:
//                           isUser ? Alignment.centerRight : Alignment.centerLeft,
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(vertical: 6),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(18),
//                               child: BackdropFilter(
//                                 filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//                                 child: Container(
//                                   padding: const EdgeInsets.all(14),
//                                   decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                       colors: isUser
//                                           ? [
//                                         Colors.purple.withOpacity(0.35),
//                                         Colors.blue.withOpacity(0.25)
//                                       ]
//                                           : [
//                                         Colors.white.withOpacity(0.4),
//                                         Colors.grey.withOpacity(0.2)
//                                       ],
//                                       begin: Alignment.topLeft,
//                                       end: Alignment.bottomRight,
//                                     ),
//                                     borderRadius: BorderRadius.circular(18),
//                                     border: Border.all(
//                                       color: Colors.white.withOpacity(0.3),
//                                     ),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: isUser
//                                             ? Colors.deepPurple.withOpacity(0.2)
//                                             : Colors.black.withOpacity(0.1),
//                                         blurRadius: 8,
//                                         offset: const Offset(2, 4),
//                                       )
//                                     ],
//                                   ),
//                                   child: Text(
//                                     msg['text'] ?? "",
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                       color: isUser ? Colors.white : Colors.black87,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   // Input Bar
//                   Container(
//                     margin: const EdgeInsets.all(12),
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.25),
//                       borderRadius: BorderRadius.circular(30),
//                       border: Border.all(color: Colors.white.withOpacity(0.3)),
//                     ),
//                     child: Row(
//                       children: [
//                         SpeedDial(
//                           icon: Icons.add,
//                           activeIcon: Icons.close,
//                           backgroundColor: Colors.white,
//                           foregroundColor: Colors.black,
//                           overlayOpacity: 0.4,
//                           elevation: 4,
//                           curve: Curves.easeInOut,
//                           children: [
//                             SpeedDialChild(
//                               child: _glassIcon(Icons.camera_alt),
//                               backgroundColor: Colors.purple[200],
//                               onTap: _openCamera,
//                             ),
//                             SpeedDialChild(
//                               child: _glassIcon(Icons.insert_drive_file),
//                               backgroundColor: Colors.purple[200],
//                               onTap: _openFileManager,
//                             ),
//                             SpeedDialChild(
//                               child: _glassIcon(Icons.image),
//                               backgroundColor: Colors.purple[200],
//                               onTap: _openGallery,
//                             ),
//                           ],
//                         ),
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.25),
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 1,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: IconButton(
//                             icon: const Icon(Icons.mic_none, color: Colors.deepPurple),
//                             onPressed: () {},
//                           ),
//                         ),
//                         Expanded(
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(horizontal: 8),
//                             padding: const EdgeInsets.symmetric(horizontal: 12),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.25),
//                               borderRadius: BorderRadius.circular(20),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.1),
//                                   blurRadius: 1,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: TextField(
//                               controller: _messageController,
//                               decoration: const InputDecoration(
//                                 hintText: "Write here...",
//                                 border: InputBorder.none,
//                               ),
//                             ),
//                           ),
//                         ),
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.25),
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 1,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: IconButton(
//                             icon: const Icon(Icons.send, color: Colors.deepPurple),
//                             onPressed: _sendMessage,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }



import 'dart:math';
import 'dart:ui';
import 'package:bresol_ai_chatbot/helper/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart' as api; // <-- prefix added

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

class CircleWavePainter extends CustomPainter {
  final double progress;
  CircleWavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.2;
    final dotCount = 40;

    for (int i = 0; i < dotCount; i++) {
      final angle = (2 * pi / dotCount) * i + progress;
      final dx = center.dx + radius * cos(angle);
      final dy = center.dy + radius * sin(angle);

      final paint = Paint()
        ..color = Colors.deepPurple.withOpacity(0.6 + 0.4 * sin(angle + progress))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dx, dy), 4, paint);
    }
  }

  @override
  bool shouldRepaint(CircleWavePainter oldDelegate) => true;
}

class ChatBotScreen extends StatefulWidget {
  final api.ChatSession? session; // 👈 Optional: load old session

  const ChatBotScreen({super.key, this.session});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen>
    with TickerProviderStateMixin {
  List<Map<String, String>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late GenerativeModel _model;
  late AnimationController _bgController;
  late AnimationController _circleController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final ImagePicker _picker = ImagePicker();
  api.ChatSession? _currentSession;

  @override
  void initState() {
    super.initState();

    _model = GenerativeModel(model: "gemini-1.5-flash", apiKey: apiKey);
//     _model = GenerativeModel(model: "gemini-1.5-flash", apiKey: apiKey);

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // ✅ Start fresh or load old session based on drawer selection
    if (widget.session != null) {
      _loadSession(widget.session!);
    } else {
      _startNewChatSession();
    }
  }

  void _startNewChatSession() {
    setState(() {
      _messages = [];
      _currentSession = api.ChatSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: "Chat with AI",
        createdAt: DateTime.now(),
        messages: [],
      );
    });
  }

  void _loadSession(api.ChatSession session) {
    setState(() {
      _currentSession = session;
      _messages = session.messages
          .map((msg) => {
        "sender": msg['sender'].toString(),
        "text": msg['text'].toString(),
      })
          .toList();
    });

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _circleController.dispose();
    _fadeController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveChatHistory() async {
    if (_currentSession == null) return;
    _currentSession!.messages = _messages
        .map((msg) => {"role": msg['sender'], "text": msg['text']})
        .toList();

    await api.ApiService.saveChatHistory([_currentSession!]);
  }

  Future<void> _openCamera() async {
    final pickedFile =
    await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (pickedFile != null) debugPrint("Camera image: ${pickedFile.path}");
  }

  Future<void> _openGallery() async {
    final pickedFile =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) debugPrint("Gallery image: ${pickedFile.path}");
  }

  Future<void> _openFileManager() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) debugPrint("Picked file: ${result.files.single.path}");
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    String userInput = _messageController.text;
    setState(() {
      _messages.add({"sender": "user", "text": userInput});
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await _model.generateContent([Content.text(userInput)]);
      setState(() {
        _messages.add({
          "sender": "bot",
          "text": response.text ?? "⚠️ No response from Gemini"
        });
      });
      _scrollToBottom();
      await _saveChatHistory();
    } catch (e) {
      setState(() {
        _messages.add({"sender": "bot", "text": "⚠️ Error: $e"});
      });
    }
  }

  void _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _glassIcon(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation:
      Listenable.merge([_bgController, _circleController, _fadeController]),
      builder: (context, _) {
        return Scaffold(
          body: CustomPaint(
            painter: GlassBackgroundPainter(offset: _bgController.value * 20),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CustomPaint(
                    painter: CircleWavePainter(_circleController.value * 2 * pi),
                    child: Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Text(
                          "Hi, can I help you?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isUser = msg['sender'] == 'user';

                        return Align(
                          alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isUser
                                          ? [
                                        Colors.purple.withOpacity(0.35),
                                        Colors.blue.withOpacity(0.25)
                                      ]
                                          : [
                                        Colors.white.withOpacity(0.4),
                                        Colors.grey.withOpacity(0.2)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isUser
                                            ? Colors.deepPurple.withOpacity(0.2)
                                            : Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(2, 4),
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    msg['text'] ?? "",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color:
                                      isUser ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Input Bar
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        SpeedDial(
                          icon: Icons.add,
                          activeIcon: Icons.close,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          overlayOpacity: 0.4,
                          elevation: 4,
                          curve: Curves.easeInOut,
                          children: [
                            SpeedDialChild(
                              child: _glassIcon(Icons.camera_alt),
                              backgroundColor: Colors.purple[200],
                              onTap: _openCamera,
                            ),
                            SpeedDialChild(
                              child: _glassIcon(Icons.insert_drive_file),
                              backgroundColor: Colors.purple[200],
                              onTap: _openFileManager,
                            ),
                            SpeedDialChild(
                              child: _glassIcon(Icons.image),
                              backgroundColor: Colors.purple[200],
                              onTap: _openGallery,
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.mic_none,
                                color: Colors.deepPurple),
                            onPressed: () {},
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: "Write here...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon:
                            const Icon(Icons.send, color: Colors.deepPurple),
                            onPressed: _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
