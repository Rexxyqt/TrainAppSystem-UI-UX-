import 'dart:math';
import 'package:flutter/material.dart';
import 'verify.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _showMessage = false;
  String _message = '';
  String _verificationCode = '';

  String _generateCode() {
    var rng = Random();
    return (10000 + rng.nextInt(90000)).toString();
  }

  void _sendCode() {
    final phoneNumber = _phoneController.text.trim();
    _verificationCode = _generateCode();

    setState(() {
      _message = 'We’ve sent a verification code to:\n$phoneNumber\n\n'
          'Your code is:\n$_verificationCode\n\n'
          'Please enter this code to reset your password.';
      _showMessage = true;
    });

    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _showMessage = false;
      });

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  VerifyCodeScreen(verificationCode: _verificationCode)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_rounded),
                      onPressed: () => Navigator.pop(context),
                      iconSize: 28,
                      color: Colors.black,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Forgot your\npassword?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Enter your phone number below and we'll send you a code to reset your password.",
                      style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Phone number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 16.0),
                      ),
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.start,
                      autofocus: true,
                    ),
                    SizedBox(height: 30),
                    Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _sendCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Send Code',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
              
              if (_showMessage)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.sms, color: Colors.green[800], size: 30),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _message,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
