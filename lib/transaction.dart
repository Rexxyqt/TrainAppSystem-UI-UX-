import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class TransactionsHistoryScreen extends StatefulWidget {
  @override
  _TransactionsHistoryScreenState createState() =>
      _TransactionsHistoryScreenState();
}

class _TransactionsHistoryScreenState extends State<TransactionsHistoryScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemeAndTransactions();
  }

  Future<void> _loadThemeAndTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });

    String? savedData = prefs.getString('lrt_transactions');
    if (savedData != null) {
      setState(() {
        transactions = List<Map<String, dynamic>>.from(json.decode(savedData));
      });
    }
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      List<String> months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return '${months[parsedDate.month - 1]} ${parsedDate.day}, ${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.green[900],
        title: const Text(
          'TRANSACTIONS HISTORY',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        foregroundColor: isDarkMode ? Colors.white : Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Recent Transactions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          ...transactions.map((day) => buildTransactionGroup(day)).toList(),
        ],
      ),
    );
  }

  Widget buildTransactionGroup(Map<String, dynamic> day) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatDate(day['date']),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        ...day['entries'].map<Widget>((entry) {
          Color amountColor =
              entry['type'] == 'topup' ? Colors.green : Colors.red;
          IconData icon = entry['type'] == 'topup'
              ? Icons.trending_up
              : Icons.keyboard_double_arrow_down_rounded;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color:
                      isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              elevation: 4,
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                title: Text(
                  entry['title'],
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry['amount'],
                      style: TextStyle(
                        color: amountColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      icon,
                      color: amountColor,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
