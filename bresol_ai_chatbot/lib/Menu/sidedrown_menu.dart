//
// import 'package:flutter/material.dart';
// import '../services/api_service.dart' as api; // <- prefix
//
// class SideDrownMenu extends StatefulWidget {
//   const SideDrownMenu({super.key});
//
//   @override
//   State<SideDrownMenu> createState() => _SideDrownMenuState();
// }
//
// class _SideDrownMenuState extends State<SideDrownMenu> {
//   List<api.ChatSession> _chatSessions = []; // <- use prefixed class
//   bool _loading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadChatHistory();
//   }
//
//
//   Future<void> _loadChatHistory() async {
//     print("📡 Fetching chat history...");
//     setState(() => _loading = true);
//
//     final sessions = await api.ApiService.getChatHistory();
//
//     print("📦 Sessions fetched: ${sessions.length}");
//     for (var s in sessions) {
//       print("🧵 ${s.id} | ${s.title} | ${s.createdAt}");
//       print("💬 Messages: ${s.messages}");
//     }
//
//     setState(() {
//       _chatSessions = sessions;
//       _loading = false;
//     });
//   }
//
//
//
//   Future<void> _deleteChat(String sessionId) async {
//     final success = await api.ApiService.deleteChatSession(sessionId);
//     if (success) {
//       _chatSessions.removeWhere((session) => session.id == sessionId);
//       setState(() {});
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Chat deleted')));
//     } else {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('Failed to delete chat')));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: SafeArea(
//         child: _loading
//             ? const Center(child: CircularProgressIndicator())
//             : ListView.builder(
//           padding: EdgeInsets.zero,
//           itemCount: _chatSessions.length,
//           itemBuilder: (context, index) {
//             final chat = _chatSessions[index];
//             return ListTile(
//               title: Text(chat.title),
//               subtitle: Text(
//                   chat.createdAt.toLocal().toString().split('.')[0]),
//               trailing: IconButton(
//                 icon: const Icon(Icons.delete),
//                 onPressed: () => _deleteChat(chat.id),
//               ),
//               onTap: () {
//                 Navigator.pop(context);
//                 // Navigate to chat detail if needed
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
import 'package:flutter/material.dart';
import '../services/api_service.dart' as api;
import '../ui/chat_bot_screen.dart';

class SideDrownMenu extends StatefulWidget {
  const SideDrownMenu({super.key});

  @override
  State<SideDrownMenu> createState() => _SideDrownMenuState();
}

class _SideDrownMenuState extends State<SideDrownMenu> {
  List<api.ChatSession> _chatSessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    print("📡 Fetching chat history...");
    setState(() => _loading = true);

    final sessions = await api.ApiService.getChatHistory();

    print("📦 Sessions fetched: ${sessions.length}");
    for (var s in sessions) {
      print("🧵 ${s.id} | ${s.title} | ${s.createdAt}");
      print("💬 Messages: ${s.messages}");
    }

    setState(() {
      _chatSessions = sessions;
      _loading = false;
    });
  }

  Future<void> _deleteChat(String sessionId) async {
    final success = await api.ApiService.deleteChatSession(sessionId);
    if (success) {
      _chatSessions.removeWhere((session) => session.id == sessionId);
      setState(() {});
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Chat deleted')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to delete chat')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: _chatSessions.length,
          itemBuilder: (context, index) {
            final chat = _chatSessions[index];
            return ListTile(
              title: Text(chat.title),
              subtitle:
              Text(chat.createdAt.toLocal().toString().split('.')[0]),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteChat(chat.id),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatBotScreen(session: chat),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
