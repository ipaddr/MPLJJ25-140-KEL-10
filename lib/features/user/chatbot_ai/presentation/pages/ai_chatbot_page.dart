import 'package:flutter/material.dart';
import 'package:socio_care/features/user/core_user/presentation/widgets/user_bottom_navigation_bar.dart';

class AiChatbotPage extends StatefulWidget {
  const AiChatbotPage({super.key});

  @override
  State<AiChatbotPage> createState() => _AiChatbotPageState();
}

class _AiChatbotPageState extends State<AiChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(text: 'This is message 5', isUser: false),
    ChatMessage(text: 'This is message 4', isUser: true),
    ChatMessage(text: 'This is message 3', isUser: false),
    ChatMessage(text: 'This is message 2', isUser: true),
    ChatMessage(text: 'This is message 1', isUser: false),
  ];

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Riwayat Chat"),
          content: const Text(
            "Apakah Anda yakin ingin menghapus semua riwayat chat? Tindakan ini tidak dapat dibatalkan.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _messages.clear();
                });
                Navigator.of(context).pop();
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(text: _messageController.text, isUser: true),
        );
        // Here you would typically send the message to your AI service
        // and then add the AI's response when received
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chatbot AI", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _showClearChatDialog(context);
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade200],
          ),
        ),
        child: Column(
          children: [
            // Chat messages list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                reverse: true, // To show latest messages at the bottom
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Align(
                    alignment:
                        message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                        color:
                            message.isUser
                                ? Colors.blue[100]
                                : Colors.grey[300],
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(message.text),
                    ),
                  );
                },
              ),
            ),
            // Input field for sending messages
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Tanyakan bantuan yang kamu butuhkan…',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const UserBottomNavigationBar(
        selectedIndex: 1, // Chatbot is the second item
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
