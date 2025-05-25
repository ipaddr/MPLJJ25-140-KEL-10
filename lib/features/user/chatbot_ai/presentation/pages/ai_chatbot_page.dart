import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:socio_care/features/user/core_user/presentation/widgets/user_bottom_navigation_bar.dart';

class AiChatbotPage extends StatefulWidget {
  const AiChatbotPage({super.key});

  @override
  State<AiChatbotPage> createState() => _AiChatbotPageState();
}

class _AiChatbotPageState extends State<AiChatbotPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  late GenerativeModel _model;
  late ChatSession _chatSession;
  bool _isLoading = false;
  bool _isInitialized = false;
  User? _currentUser;
  String? _conversationId;

  // Animation controllers untuk typing indicator
  late AnimationController _typingAnimationController;
  late AnimationController _fadeAnimationController;

  // Ganti dengan API Key Gemini Anda yang valid
  static const String _geminiApiKey = 'AIzaSyAfxsfaOrT8FzmEDz23KnheplbypSu1TRQ';

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _initializeServices();
    _loadWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      _currentUser = FirebaseAuth.instance.currentUser;

      // Initialize Gemini AI dengan model yang didukung
      _model = GenerativeModel(
        model: 'gemini-2.0-flash', // Model yang didukung
        apiKey: _geminiApiKey,
        systemInstruction: Content.system('''
Anda adalah SocioCare Assistant, asisten AI yang membantu pengguna dalam hal program bantuan sosial di Indonesia. 

Tugas Anda:
1. Memberikan informasi tentang program bantuan sosial seperti PKH, BPNT, Kartu Prakerja, KIP, dll
2. Membantu pengguna memahami syarat dan cara pendaftaran program bantuan
3. Memberikan panduan untuk mengisi formulir dan dokumen yang diperlukan
4. Menjawab pertanyaan seputar kesehatan, pendidikan, dan ekonomi dasar
5. Memberikan motivasi dan dukungan kepada pengguna
6. Membantu mencari program bantuan yang sesuai dengan kondisi pengguna

Aturan:
- Selalu gunakan bahasa Indonesia yang sopan dan mudah dipahami
- Berikan informasi yang akurat dan terkini tentang program bantuan sosial Indonesia
- Jika tidak yakin dengan informasi, sarankan untuk menghubungi instansi terkait
- Bersikap empati dan membantu
- Fokus pada topik bantuan sosial dan kesejahteraan masyarakat
- Jangan memberikan informasi yang menyesatkan tentang program pemerintah
- Berikan respons yang terstruktur dan mudah dipahami
- Gunakan emoji untuk membuat percakapan lebih ramah

Contoh program bantuan yang bisa Anda bantu:
- Program Keluarga Harapan (PKH)
- Bantuan Pangan Non Tunai (BPNT)
- Kartu Indonesia Pintar (KIP)
- Kartu Prakerja
- Program Indonesia Sehat (PIS)
- Bantuan Subsidi Upah (BSU)
- Dan program bantuan sosial lainnya
'''),
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(
            HarmCategory.sexuallyExplicit,
            HarmBlockThreshold.medium,
          ),
          SafetySetting(
            HarmCategory.dangerousContent,
            HarmBlockThreshold.medium,
          ),
        ],
      );

      _chatSession = _model.startChat();

      setState(() {
        _isInitialized = true;
      });

      // Load previous conversation if exists
      await _loadPreviousConversation();
    } catch (e) {
      print('Error initializing services: $e');
      setState(() {
        _isInitialized = false;
      });

      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _geminiApiKey == 'AIzaSyAfxsfaOrT8FzmEDz23KnheplbypSu1TRQ'
                  ? 'API Key Gemini belum diatur. Silakan hubungi administrator.'
                  : 'Gagal menghubungkan ke AI Assistant. Periksa koneksi internet Anda.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Coba Lagi',
              textColor: Colors.white,
              onPressed: () => _initializeServices(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadWelcomeMessage() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text:
                'Halo! Saya SocioCare Assistant 🤖\n\n'
                'Saya siap membantu Anda dengan:\n'
                '• 📋 Informasi program bantuan sosial\n'
                '• 📝 Cara pendaftaran program pemerintah\n'
                '• ✅ Syarat dan ketentuan bantuan\n'
                '• 📄 Panduan mengisi formulir\n'
                '• 💡 Tips kesehatan dan pendidikan\n'
                '• 🔍 Pencarian program yang sesuai\n\n'
                'Silakan tanyakan apa saja yang ingin Anda ketahui! 😊',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    }
  }

  Future<void> _loadPreviousConversation() async {
    if (_currentUser == null) return;

    try {
      // Get or create conversation document
      final conversationRef = FirebaseFirestore.instance
          .collection('chat_conversations')
          .doc(_currentUser!.uid);

      final conversationDoc = await conversationRef.get();

      if (conversationDoc.exists) {
        _conversationId = conversationDoc.id;

        // Load recent messages (last 20)
        final messagesQuery =
            await FirebaseFirestore.instance
                .collection('chat_conversations')
                .doc(_conversationId)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .limit(20)
                .get();

        final List<ChatMessage> loadedMessages =
            messagesQuery.docs.map((doc) {
              final data = doc.data();
              return ChatMessage(
                text: data['text'] ?? '',
                isUser: data['isUser'] ?? false,
                timestamp: data['timestamp']?.toDate() ?? DateTime.now(),
              );
            }).toList();

        setState(() {
          _messages.addAll(loadedMessages);
        });
      } else {
        // Create new conversation
        await conversationRef.set({
          'userId': _currentUser!.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessageAt': FieldValue.serverTimestamp(),
        });
        _conversationId = conversationRef.id;
      }
    } catch (e) {
      print('Error loading conversation: $e');
    }
  }

  Future<void> _saveMessageToFirestore(ChatMessage message) async {
    if (_currentUser == null || _conversationId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('chat_conversations')
          .doc(_conversationId)
          .collection('messages')
          .add({
            'text': message.text,
            'isUser': message.isUser,
            'timestamp': FieldValue.serverTimestamp(),
            'userId': _currentUser!.uid,
          });

      // Update conversation last message time
      await FirebaseFirestore.instance
          .collection('chat_conversations')
          .doc(_conversationId)
          .update({
            'lastMessageAt': FieldValue.serverTimestamp(),
            'messageCount': FieldValue.increment(1),
          });
    } catch (e) {
      print('Error saving message: $e');
    }
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 8),
              Text('Hapus Riwayat Chat'),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus semua riwayat percakapan? '
            'Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearChatHistory();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearChatHistory() async {
    try {
      setState(() {
        _messages.clear();
      });

      // Delete from Firestore
      if (_currentUser != null && _conversationId != null) {
        final messagesRef = FirebaseFirestore.instance
            .collection('chat_conversations')
            .doc(_conversationId)
            .collection('messages');

        final messages = await messagesRef.get();
        for (var doc in messages.docs) {
          await doc.reference.delete();
        }

        // Reset conversation
        await FirebaseFirestore.instance
            .collection('chat_conversations')
            .doc(_conversationId)
            .update({
              'lastMessageAt': FieldValue.serverTimestamp(),
              'messageCount': 0,
            });
      }

      // Restart chat session
      _chatSession = _model.startChat();

      // Show welcome message again
      _loadWelcomeMessage();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Riwayat chat berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus riwayat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startTypingAnimation() {
    _fadeAnimationController.forward();
    _typingAnimationController.repeat();
  }

  void _stopTypingAnimation() {
    _typingAnimationController.stop();
    _fadeAnimationController.reverse();
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || !_isInitialized) return;

    final userMessage = ChatMessage(
      text: messageText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, userMessage);
      _isLoading = true;
    });

    // Start typing animation
    _startTypingAnimation();

    _messageController.clear();
    _scrollToBottom();

    // Save user message to Firestore
    await _saveMessageToFirestore(userMessage);

    try {
      // Send message to Gemini AI dengan error handling yang lebih baik
      final response = await _chatSession.sendMessage(
        Content.text(messageText),
      );

      final responseText = response.text;

      if (responseText != null && responseText.isNotEmpty) {
        // Stop typing animation
        _stopTypingAnimation();

        final aiMessage = ChatMessage(
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
        );

        setState(() {
          _messages.insert(0, aiMessage);
          _isLoading = false;
        });

        // Save AI response to Firestore
        await _saveMessageToFirestore(aiMessage);

        _scrollToBottom();
      } else {
        throw Exception('Response kosong dari AI');
      }
    } catch (e) {
      print('Error sending message to AI: $e');

      // Stop typing animation
      _stopTypingAnimation();

      String errorText;
      if (e.toString().contains('API_KEY_INVALID')) {
        errorText = 'API Key tidak valid. Silakan hubungi administrator.';
      } else if (e.toString().contains('QUOTA_EXCEEDED')) {
        errorText = 'Kuota API telah habis. Silakan coba lagi nanti.';
      } else if (e.toString().contains('model')) {
        errorText = 'Model AI tidak tersedia. Silakan coba lagi nanti.';
      } else {
        errorText =
            'Maaf, terjadi kesalahan saat memproses pesan Anda. '
            'Silakan coba lagi dalam beberapa saat. 🔄';
      }

      final errorMessage = ChatMessage(
        text: errorText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.insert(0, errorMessage);
        _isLoading = false;
      });

      await _saveMessageToFirestore(errorMessage);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pertanyaan Cepat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildQuickActionButton(
                  '📋 Apa itu Program Keluarga Harapan (PKH)?',
                  'Apa itu Program Keluarga Harapan (PKH) dan bagaimana cara mendaftarnya?',
                ),
                _buildQuickActionButton(
                  '🍚 Informasi BPNT (Bantuan Pangan Non Tunai)',
                  'Bagaimana cara mendaftar BPNT dan apa syarat-syaratnya?',
                ),
                _buildQuickActionButton(
                  '🎓 Kartu Indonesia Pintar (KIP)',
                  'Saya ingin tahu tentang program Kartu Indonesia Pintar untuk anak saya',
                ),
                _buildQuickActionButton(
                  '💼 Kartu Prakerja',
                  'Bagaimana cara mendaftar Kartu Prakerja dan pelatihan apa saja yang tersedia?',
                ),
                _buildQuickActionButton(
                  '🏥 Program Indonesia Sehat',
                  'Apa saja manfaat dari program Indonesia Sehat dan bagaimana cara mendaftarnya?',
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildQuickActionButton(String title, String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: TextButton(
        onPressed: () {
          Navigator.pop(context);
          _messageController.text = message;
          _sendMessage();
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(16),
          backgroundColor: Colors.blue.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(color: Colors.blue.shade700, fontSize: 14),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SocioCare Assistant",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade700, Colors.blue.shade900],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showQuickActions,
            tooltip: 'Pertanyaan Cepat',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => _showClearChatDialog(context),
            tooltip: 'Hapus Riwayat Chat',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Connection Status
            if (!_isInitialized)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.orange.shade100,
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Menghubungkan ke AI Assistant...',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Chat Messages
            Expanded(
              child:
                  _messages.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Memuat percakapan...'),
                          ],
                        ),
                      )
                      : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_isLoading && index == 0) {
                            return _buildTypingIndicator();
                          }

                          final messageIndex = _isLoading ? index - 1 : index;
                          return _buildMessageBubble(_messages[messageIndex]);
                        },
                      ),
            ),

            // Message Input
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Quick Actions Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      onPressed: _isInitialized ? _showQuickActions : null,
                      icon: Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue.shade700,
                      ),
                      tooltip: 'Pertanyaan Cepat',
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Message Input Field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _messageController,
                        enabled: _isInitialized,
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText:
                              _isInitialized
                                  ? 'Ketik pesan Anda...'
                                  : 'Menunggu koneksi...',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Send Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade800],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed:
                          (_isInitialized && !_isLoading) ? _sendMessage : null,
                      icon: Icon(
                        _isLoading ? Icons.stop : Icons.send,
                        color: Colors.white,
                      ),
                      tooltip: _isLoading ? 'Stop' : 'Kirim Pesan',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const UserBottomNavigationBar(selectedIndex: 1),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue.shade600 : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color:
                          message.isUser
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (message.isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.person, color: Colors.grey.shade600, size: 24),
            ),
          ],
        ],
      ),
    );
  }

  // Updated typing indicator dengan animasi seperti Facebook Messenger
  Widget _buildTypingIndicator() {
    return FadeTransition(
      opacity: _fadeAnimationController,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar chatbot
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),

            // Animated typing bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated dots seperti Facebook Messenger
                  AnimatedBuilder(
                    animation: _typingAnimationController,
                    builder: (context, child) {
                      return Row(
                        children: List.generate(3, (index) {
                          // Calculate animation offset for each dot
                          final animationValue =
                              _typingAnimationController.value;
                          final delay = index * 0.2;
                          final adjustedValue = (animationValue - delay).clamp(
                            0.0,
                            1.0,
                          );

                          // Create bounce effect
                          final bounceValue = Curves.easeInOut.transform(
                            (adjustedValue * 2).clamp(0.0, 1.0),
                          );

                          final offset =
                              bounceValue > 0.5
                                  ? Tween<double>(
                                    begin: 0,
                                    end: -8,
                                  ).transform((bounceValue - 0.5) * 2)
                                  : Tween<double>(
                                    begin: -8,
                                    end: 0,
                                  ).transform(bounceValue * 2);

                          return Transform.translate(
                            offset: Offset(0, offset),
                            child: Container(
                              margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(width: 12),

                  // "Sedang mengetik..." text dengan fade animation
                  AnimatedBuilder(
                    animation: _fadeAnimationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimationController.value * 0.7,
                        child: Text(
                          'SocioCare sedang mengetik',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Baru saja';
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}
