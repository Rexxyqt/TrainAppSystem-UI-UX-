import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class LoadPage extends StatefulWidget {
  final bool isDarkMode;
  final Function() onBalanceUpdated;

  const LoadPage({
    Key? key,
    required this.isDarkMode,
    required this.onBalanceUpdated,
  }) : super(key: key);

  @override
  _LoadPageState createState() => _LoadPageState();
}

class _LoadPageState extends State<LoadPage> {
  double _currentBalance = 0.0;
  String _beepCardNumber = '1234567890';
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadCurrentBalance();
  }

  void _loadCurrentBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentBalance = prefs.getDouble('lrt_balance') ?? 100.0;
    });
  }

  void _saveBalance(double newBalance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('lrt_balance', newBalance);
    widget.onBalanceUpdated();
  }

  Future<void> _recordTransaction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toIso8601String().split('T')[0];
    String? existingData = prefs.getString('lrt_transactions');

    List<Map<String, dynamic>> transactions = [];

    if (existingData != null) {
      transactions = List<Map<String, dynamic>>.from(json.decode(existingData));
    }

    Map<String, dynamic>? todayEntry = transactions.firstWhere(
      (item) => item['date'] == today,
      orElse: () => {},
    );

    Map<String, String> newEntry = {
      'title': 'LRT Fare',
      'amount': '-₱15.00',
      'type': 'deduct',
    };

    if (todayEntry.isNotEmpty) {
      todayEntry['entries'].add(newEntry);
    } else {
      todayEntry = {
        'date': today,
        'entries': [newEntry],
      };
      transactions.insert(0, todayEntry);
    }

    await prefs.setString('lrt_transactions', json.encode(transactions));
  }

  void _deductFare() async {
    const fare = 15.0;

    if (_currentBalance >= fare) {
      setState(() {
        _currentBalance -= fare;
      });
      _saveBalance(_currentBalance);
      await _recordTransaction();
      await _flutterTts.speak("Scan successful. ₱15 deducted.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('₱15 fare deducted.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      await _flutterTts.speak("Insufficient balance.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showScanInstruction() async {
    // Show the dialog immediately
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Scan Instruction"),
        content: const Text(
          "Please scan this QR code on the LRT beep machine to enter.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );

    // Speak the instruction simultaneously
    await _flutterTts.speak(
      "Please scan this QR code on the LRT beep machine to enter.",
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? Colors.grey[900] : Colors.grey[100];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[850] : Colors.green[700],
        title:
            const Text("Beep Card QR", style: TextStyle(color: Colors.white)),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: "Scan Instruction",
            onPressed: _showScanInstruction,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: GestureDetector(
                    onTap: _deductFare,
                    child: QrImageView(
                      data: _beepCardNumber,
                      size: 280, // big QR
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildInfoTile("Card Number", _beepCardNumber, textColor),
              const SizedBox(height: 20),
              _buildInfoTile(
                "Current Balance",
                '₱${_currentBalance.toStringAsFixed(2)}',
                Colors.green[700]!,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: color.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
