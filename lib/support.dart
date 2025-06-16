import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ChatSupportApp());
}

class ChatSupportApp extends StatelessWidget {
  const ChatSupportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LRT Support',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  final List<ChatMessage> _messages = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool isDarkMode = false;

  final List<String> stations = [
    "MIA",
    "Baclaran",
    "EDSA",
    "Libertad",
    "Gil Puyat",
    "Vito Cruz",
    "Quirino",
    "Pedro Gil",
    "UN Avenue",
    "Central Terminal",
    "Carriedo",
    "Doroteo Jose",
    "Bambang",
    "Tayuman",
    "Blumentritt",
    "Abad Santos",
    "R. Papa",
    "5th Avenue",
    "Monumento",
    "Balintawak",
    "Roosevelt",
  ];

  final List<Map<String, dynamic>> statuses = [
    {"label": "Normal", "description": "Smooth passenger flow", "icon": "✅"},
    {"label": "Moderate", "description": "Moderate crowd", "icon": "🟠"},
    {"label": "High", "description": "Crowded", "icon": "⚠️"},
    {"label": "Severe", "description": "Severely crowded", "icon": "🚨"},
  ];

  Map<String, Map<String, dynamic>> stationCrowdStatus = {};

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadTheme();
    _generateCrowdStatus();
    _addAssistantMessage(
        "Hello! I am your LRT Assistant. How can I help you today?");
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _generateCrowdStatus() {
    final random = Random();
    for (final station in stations) {
      stationCrowdStatus[station.toLowerCase()] =
          statuses[random.nextInt(statuses.length)];
    }
  }

  void _addAssistantMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        sender: "LRT Assistant",
        isUser: false,
        time: DateTime.now(),
      ));
    });
    _tts.speak(text);
  }

  void _handleSendMessage([String? overrideText]) {
    final text = overrideText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        sender: "You",
        isUser: true,
        time: DateTime.now(),
      ));
    });
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 700), () {
      final reply = _getSmartReply(text);
      _addAssistantMessage(reply);
    });
  }

  String _getSmartReply(String message) {
    final lower = message.toLowerCase();

    // Check for station status request
    for (final station in stations) {
      if (lower.contains(station.toLowerCase()) &&
          (lower.contains("status") ||
              lower.contains("crowd") ||
              lower.contains("crowded"))) {
        final status = stationCrowdStatus[station.toLowerCase()];
        return "${status?["icon"]} ${station} Station is currently ${status?["label"]} - ${status?["description"]}.";
      }
    }

    // Predefined responses
    if (lower.contains("log in") || lower.contains("login")) {
      return "Make sure you're using the correct email and password. You may also reset it using the Forgot Password option.";
    } else if (lower.contains("balance")) {
      return "You can check your LRT balance from the Home screen’s green card section.";
    } else if (lower.contains("fare") || lower.contains("price")) {
      return "Use the Fare Checker screen to get fare details from Roosevelt to Dr. Santos.";
    } else if (lower.contains("senior") || lower.contains("pwd")) {
      return "Yes! Senior citizens and PWDs are eligible for fare discounts. Please register your card at the station.";
    } else if (lower.contains("gcash") ||
        lower.contains("top up") ||
        lower.contains("load")) {
      return "To load via GCash, tap 'Load', enter your number, amount, and 4-digit PIN.";
    } else if (lower.contains("train") && lower.contains("delay")) {
      return "Train delays may happen due to system checks. You can monitor train timers on the Home screen.";
    } else if (lower.contains("problem") && lower.contains("station")) {
      return "Please report any station issues (crowd, security, etc.) to the nearest officer.";
    } else if (lower.contains("card") && lower.contains("not working")) {
      return "Try tapping again. If it still doesn’t work, visit the nearest station personnel.";
    } else if (lower.contains("bug") || lower.contains("crash")) {
      return "Try restarting or reinstalling the app. You may also clear app cache.";
    } else if (lower.contains("announcement") || lower.contains("advisory")) {
      return "Check LRT Facebook or the in-app news section for the latest service updates.";
    } else if (lower.contains("schedule") || lower.contains("time")) {
      return "LRT trains usually operate from 4:30 AM to 10:00 PM daily.";
    } else if (lower.contains("hi") || lower.contains("hello")) {
      return "Hi there! How can I assist you with your travel today?";
    } else if (lower.contains("support") || lower.contains("human")) {
      return "If needed, we can redirect you to a human assistant. Just let us know.";
    } else if (lower.contains("nearest") && lower.contains("station")) {
      return "Tap the Nearest Station icon on your app to find one close to you.";
    } else {
      return "Thank you for your question. We'll connect you with support if needed.";
    }
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _messageController.text = result.recognizedWords;
          });

          if (result.finalResult) {
            _handleSendMessage(result.recognizedWords);
            setState(() => _isListening = false);
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark || isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text("SUPPORT"),
        centerTitle: true,
        backgroundColor: isDark ? Colors.grey[900] : Colors.green[900],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index], isDark);
              },
            ),
          ),
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage msg, bool isDark) {
    final isUser = msg.isUser;
    final timeString =
        '${msg.time.hour}:${msg.time.minute.toString().padLeft(2, '0')}';

    return Semantics(
      label: "${msg.sender} says: ${msg.text}",
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser) const CircleAvatar(child: Icon(Icons.support_agent)),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: isUser
                      ? const Color(0xff056d08)
                      : (isDark ? Colors.grey[800] : Colors.grey.shade300),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 0),
                    bottomRight: Radius.circular(isUser ? 0 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      msg.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: isUser
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeString,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey[400] : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 3, offset: Offset(0, -1)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic_off : Icons.mic,
              color: const Color(0xff056d08),
            ),
            onPressed: _startListening,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: "Type or speak...",
                hintStyle:
                    TextStyle(color: isDark ? Colors.grey : Colors.black45),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xff056d08)),
            onPressed: _handleSendMessage,
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final String sender;
  final bool isUser;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.isUser,
    required this.time,
  });
}
