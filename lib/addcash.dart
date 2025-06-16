import 'package:flutter/material.dart';
import 'gcash.dart';

class AddCashPage extends StatelessWidget {
  final bool isDarkMode;

  const AddCashPage({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? Color(0xFF1E1E1E) : Color(0xFFF0F0F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[900] : Color(0xff056d08),
        title: Text('Add Balance', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
          children: [
            PaymentBox(
              label: 'GCash',
              imagePath: 'assets/images/gcash.png',
              bgColor: cardColor,
              textColor: textColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GCashPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentBox extends StatelessWidget {
  final String label;
  final String imagePath;
  final VoidCallback onTap;
  final Color bgColor;
  final Color textColor;

  const PaymentBox({
    Key? key,
    required this.label,
    required this.imagePath,
    required this.onTap,
    required this.bgColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(imagePath, height: 50),
              ),
              SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
