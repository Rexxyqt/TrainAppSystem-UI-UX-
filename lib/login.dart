import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'forgotpass.dart';
import 'maincontent.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController signupEmailController = TextEditingController();
  final TextEditingController signupPasswordController =
      TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isSignupPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isPasswordMismatch = false;
  bool _isSignupEmailEmpty = false;
  bool _isPhoneEmpty = false;
  bool _isSignupPasswordEmpty = false;
  bool _isConfirmPasswordEmpty = false;

  Timer? _inactivityTimer;
  String _currentSpeechLine = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _startInactivityTimer();
    _greetUser();
  }

  void _showSubtitle(String text) {
    setState(() {
      _currentSpeechLine = text;
    });
  }

  Future<void> _speakWithSubtitle(String text) async {
    _showSubtitle(text);
    await flutterTts.speak(text);
  }

  void _greetUser() async {
    await flutterTts.setSpeechRate(1.3);
    List<String> script = [
      "Hi there! Welcome to the app! I'm here to help you get started.",
      "To sign in, make sure you are on the Sign In tab. Enter your email and password, then tap the green Sign In button.",
      "If you don't have an account yet, no worries! Just tap the Sign Up tab.",
      "Fill in your email, phone number, password, and confirm your password. Then tap Sign Up.",
      "Make sure your passwords match and all fields are filled.",
      "If you forgot your password, tap the 'Forgot Password' button under the Sign In form.",
      "Your information is safe and secure with us.",
      "Take your time, and let’s get started. You got this!"
    ];

    for (String line in script) {
      // Set subtitle text immediately
      _showSubtitle(line);

      // Speak and wait for completion
      await flutterTts.speak(line);

      // Wait for speech to complete before proceeding to the next line
      await flutterTts.awaitSpeakCompletion(true);

      // Delay a bit before displaying the next line
      await Future.delayed(Duration(seconds: 1));
    }

    // Clear subtitle after all lines are spoken
    _showSubtitle("");
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(Duration(seconds: 60), () {
      _showInactivityDialog();
    });
  }

  void _resetInactivityTimer() {
    _startInactivityTimer();
  }

  void _showInactivityDialog() {
    _speakWithSubtitle(
        "You've been inactive for a while. Are you still there?");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              "Are you still there?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          content: Text(
            "You've been inactive for a while.\nDo you still want to continue signing in or creating an account?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              child: Text(
                "Continue",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _startInactivityTimer();
                _speakWithSubtitle("Continuing your session.");
              },
            ),
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _speakWithSubtitle("Session canceled.");
                SystemNavigator.pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _signUp() async {
    setState(() {
      _isSignupEmailEmpty = signupEmailController.text.isEmpty;
      _isPhoneEmpty = phoneController.text.isEmpty;
      _isSignupPasswordEmpty = signupPasswordController.text.isEmpty;
      _isConfirmPasswordEmpty = confirmPasswordController.text.isEmpty;
    });

    if (!(_isSignupEmailEmpty ||
        _isPhoneEmpty ||
        _isSignupPasswordEmpty ||
        _isConfirmPasswordEmpty)) {
      if (signupPasswordController.text == confirmPasswordController.text) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', signupEmailController.text);
        prefs.setString('password', signupPasswordController.text);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Account Created Successfully!"),
          backgroundColor: Colors.green,
        ));

        signupEmailController.clear();
        signupPasswordController.clear();
        confirmPasswordController.clear();
        phoneController.clear();
        _tabController.animateTo(0);
      } else {
        setState(() {
          _isPasswordMismatch = true;
        });
      }
    }
  }

  Future<void> _signIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedEmail = prefs.getString('email');
    String? savedPassword = prefs.getString('password');

    if (savedEmail == emailController.text &&
        savedPassword == passwordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Successfully Logged In!"),
        backgroundColor: Colors.green,
      ));
      await flutterTts.stop();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainContent(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Invalid Email or Password!"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    _inactivityTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _resetInactivityTimer,
      onPanDown: (_) => _resetInactivityTimer(),
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                  SizedBox(height: 20),
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.green,
                    labelStyle: GoogleFonts.robotoMono(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                    tabs: [
                      Tab(text: 'Sign In'),
                      Tab(text: 'Sign Up'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSignInForm(),
                        _buildSignUpForm(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_currentSpeechLine.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _currentSpeechLine,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Let's get started by filling out the form below.",
              style: GoogleFonts.roboto(fontSize: 19)),
          SizedBox(height: 20),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: GoogleFonts.roboto(fontSize: 23),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: GoogleFonts.roboto(fontSize: 23),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            obscureText: !_isPasswordVisible,
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff056d08),
                foregroundColor: Colors.white,
                minimumSize: Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
              ),
              child: Text("Sign In",
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold, fontSize: 22)),
            ),
          ),
          SizedBox(height: 13),
          Center(
            child: TextButton(
              onPressed: () {
                _inactivityTimer?.cancel();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen()),
                );
              },
              child: Text(
                "Forgot Password?",
                style: GoogleFonts.roboto(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                    fontSize: 22),
              ),
            ),
          ),
          SizedBox(height: 10),
          Center(
              child: Text("Or sign in with",
                  style: GoogleFonts.roboto(fontSize: 19))),
          SizedBox(height: 30),
          Center(
              child:
                  _buildSocialButton("Continue with Google", isGoogle: true)),
          SizedBox(height: 20),
          Center(child: _buildSocialButton("Continue with Apple")),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Create an account below.",
              style: GoogleFonts.roboto(fontSize: 19)),
          SizedBox(height: 20),
          TextFormField(
            controller: signupEmailController,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: GoogleFonts.roboto(fontSize: 23),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              errorText:
                  _isSignupEmailEmpty && signupEmailController.text.isEmpty
                      ? 'Email is required'
                      : null,
            ),
            onChanged: (_) {
              setState(() {
                _isSignupEmailEmpty = false;
              });
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              labelStyle: GoogleFonts.roboto(fontSize: 23),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              errorText: _isPhoneEmpty && phoneController.text.isEmpty
                  ? 'Phone number is required'
                  : null,
            ),
            keyboardType: TextInputType.phone,
            onChanged: (_) {
              setState(() {
                _isPhoneEmpty = false;
              });
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: signupPasswordController,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: GoogleFonts.roboto(fontSize: 23),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isSignupPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isSignupPasswordVisible = !_isSignupPasswordVisible;
                  });
                },
              ),
              errorText: _isSignupPasswordEmpty &&
                      signupPasswordController.text.isEmpty
                  ? 'Password is required'
                  : null,
            ),
            obscureText: !_isSignupPasswordVisible,
            onChanged: (_) {
              setState(() {
                _isSignupPasswordEmpty = false;
              });
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              labelStyle: GoogleFonts.roboto(fontSize: 23),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              errorText: _isPasswordMismatch
                  ? 'Passwords do not match'
                  : _isConfirmPasswordEmpty &&
                          confirmPasswordController.text.isEmpty
                      ? 'Confirm password is required'
                      : null,
            ),
            obscureText: !_isConfirmPasswordVisible,
            onChanged: (_) {
              setState(() {
                _isConfirmPasswordEmpty = false;
                _isPasswordMismatch = false;
              });
            },
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isSignupEmailEmpty = signupEmailController.text.isEmpty;
                  _isPhoneEmpty = phoneController.text.isEmpty;
                  _isSignupPasswordEmpty =
                      signupPasswordController.text.isEmpty;
                  _isConfirmPasswordEmpty =
                      confirmPasswordController.text.isEmpty;
                });

                if (!(_isSignupEmailEmpty ||
                    _isPhoneEmpty ||
                    _isSignupPasswordEmpty ||
                    _isConfirmPasswordEmpty)) {
                  _signUp();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff056d08),
                foregroundColor: Colors.white,
                minimumSize: Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
              ),
              child: Text("Sign Up",
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold, fontSize: 22)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String text, {bool isGoogle = false}) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Image.asset(
        isGoogle ? 'assets/images/google.png' : 'assets/images/apple.png',
        height: 28, // Kaunti ng pinagaan ang height ng icon
        width: 28, // Kaunti ng pinagaan ang width ng icon
      ),
      label: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 10.0), // Kaunti rin ng liit ng padding
        child: Text(
          text,
          style: GoogleFonts.roboto(
            fontSize: 16, // Pinagaan ang font size
            fontWeight: FontWeight.bold,
            color: isGoogle ? Color(0xff000000) : Colors.black,
          ),
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey),
        padding: EdgeInsets.symmetric(
            horizontal: 20, vertical: 14), // Liitan ang vertical padding
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(30), // Konting liit ng border radius
        ),
        minimumSize: Size(260, 50), // Liitan ang lapad at taas ng button
      ),
    );
  }
}
