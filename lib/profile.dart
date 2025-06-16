import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lrtapp/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'myaccount.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ProfileScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;
  final bool isDarkMode;

  const ProfileScreen({
    Key? key,
    required this.onThemeToggle,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userEmail;
  String? userName;
  File? _avatarImage;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('email') ?? 'example@email.com';
      userName = userEmail?.split('@').first ?? 'User';
      userName = userName![0].toUpperCase() + userName!.substring(1);
      String? avatarPath = prefs.getString('avatarPath');
      if (avatarPath != null) {
        _avatarImage = File(avatarPath);
      }
    });
  }

  Future<void> _pickAvatarImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('avatarPath', pickedFile.path);
    }
  }

  Future<void> _speakText(String text) async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

  Future<void> _saveThemePreference(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          widget.isDarkMode ? Colors.black : const Color(0xfff6f8f9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: widget.isDarkMode ? Colors.white : Colors.black,
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _pickAvatarImage,
              child: CircleAvatar(
                radius: 70,
                backgroundImage: _avatarImage != null
                    ? FileImage(_avatarImage!)
                    : const AssetImage('assets/images/profile.png')
                        as ImageProvider,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.camera_alt,
                        size: 22, color: Colors.black),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              userName ?? '',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            Text(
              userEmail ?? '',
              style: TextStyle(
                fontSize: 16,
                color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildOptionTile(
                    icon: Icons.person_outline,
                    title: 'My Account',
                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyAccountPage(isDarkMode: widget.isDarkMode),
                        ),
                      );
                      if (updated == true) {
                        _loadUserDetails();
                      }
                    },
                  ),
                  _buildOptionTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    trailing: Switch(
                      value: widget.isDarkMode,
                      onChanged: (val) {
                        widget.onThemeToggle(val);
                        _saveThemePreference(val);

                        if (val == true) {
                          _speakText("Switched to dark mode.");
                        }

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              isDarkMode: val,
                              onThemeToggle: widget.onThemeToggle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _buildOptionTile(
                    icon: Icons.logout,
                    title: 'Log Out',
                    iconColor: Colors.red,
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      // Just remove session key, not all
                      await prefs.remove(
                          'loggedIn'); // or whatever key you use to detect login

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => AuthScreen()),
                        (route) => false,
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

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    Color iconColor = Colors.black,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: widget.isDarkMode
                ? Colors.transparent
                : Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(icon, color: iconColor, size: 26),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 17,
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        trailing: trailing ??
            Icon(Icons.chevron_right,
                color: widget.isDarkMode ? Colors.white : Colors.black),
        onTap: onTap,
      ),
    );
  }
}
