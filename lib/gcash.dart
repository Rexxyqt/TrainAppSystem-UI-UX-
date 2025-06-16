import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GCashPage extends StatefulWidget {
  @override
  _GCashPageState createState() => _GCashPageState();
}

class _GCashPageState extends State<GCashPage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController gcashPinController =
      TextEditingController(); // <-- new PIN controller
  double lrtBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadLrtBalance();
  }

  Future<void> _loadLrtBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lrtBalance = prefs.getDouble('lrt_balance') ?? 0.0;
    });
  }

  Future<void> _addToLrtBalance() async {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount > 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      lrtBalance += amount;
      await prefs.setDouble('lrt_balance', lrtBalance);
      await prefs.setString('phone', phoneController.text);
      await prefs.setString(
          'gcash_pin', gcashPinController.text); // <-- save pin
      amountController.clear();
      phoneController.clear();
      gcashPinController.clear();

      setState(() {}); // Update UI

      // Log the top-up in the transaction history
      _logTopUpTransaction(amount);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('₱$amount successfully added to LRT balance!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logTopUpTransaction(double amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get current date and format it
    final now = DateTime.now();
    final formattedDate = "${_monthString(now.month)} ${now.day}, ${now.year}";

    // Load existing transactions
    String? savedData = prefs.getString('lrt_transactions');
    List<Map<String, dynamic>> transactions = [];
    if (savedData != null) {
      transactions = List<Map<String, dynamic>>.from(json.decode(savedData));
    }

    // Add new top-up entry
    Map<String, dynamic> newTransaction = {
      'date': formattedDate,
      'entries': [
        {
          'title': 'TOP UP LOAD',
          'amount': '+${amount.toStringAsFixed(2)}PHP',
          'type': 'topup',
        },
      ],
    };

    // Add to the transaction list and save it
    transactions.insert(0, newTransaction); // Add to the top of the list
    await prefs.setString('lrt_transactions', json.encode(transactions));
  }

  String _monthString(int month) {
    const months = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("GCash - Add to LRT"),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/gcashlogo.png',
                width: 220, // Increased size here
                height: 220, // Increased size here
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Current LRT Balance:',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              '₱${lrtBalance.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.black,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)],
              ),
              child: TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone, color: Colors.blue),
                  labelStyle: TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)],
              ),
              child: TextField(
                controller: gcashPinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Enter GCash PIN',
                  prefixIcon: Icon(Icons.lock, color: Colors.blue),
                  labelStyle: TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12)],
              ),
              child: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter GCash Amount',
                  prefixIcon:
                      Icon(Icons.account_balance_wallet, color: Colors.blue),
                  labelStyle: TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _addToLrtBalance,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Add to LRT Balance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
