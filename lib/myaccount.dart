import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAccountPage extends StatefulWidget {
  final bool isDarkMode;

  const MyAccountPage({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  _MyAccountPageState createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newEmailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String savedPassword = '';
  bool passwordVerified = false;
  bool showSuccessMessage = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAccountInfo();
  }

  Future<void> _loadAccountInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    newEmailController.text = prefs.getString('email') ?? '';
    newPasswordController.text = '';
    phoneController.text = prefs.getString('phone') ?? '';
    savedPassword = prefs.getString('password') ?? '';
  }

  Future<void> _verifyPassword(String input) async {
    setState(() {
      passwordVerified = input == savedPassword;
      errorMessage = passwordVerified ? null : 'Incorrect current password.';
    });
  }

  Future<void> _saveChanges() async {
    if (!passwordVerified) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', newEmailController.text);
    await prefs.setString(
        'password',
        newPasswordController.text.isEmpty
            ? savedPassword
            : newPasswordController.text);
    await prefs.setString('phone', phoneController.text);

    setState(() {
      showSuccessMessage = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context, true);
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    bool enabled = true,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      enabled: enabled,
      onChanged: onChanged,
      style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon,
            color: widget.isDarkMode ? Colors.white70 : Colors.black54),
        labelText: label,
        labelStyle: TextStyle(
            color: widget.isDarkMode ? Colors.white70 : Colors.black54),
        filled: true,
        fillColor: widget.isDarkMode ? Colors.grey[850] : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: widget.isDarkMode ? Colors.white24 : Colors.black26),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: widget.isDarkMode ? Colors.blue : Colors.blue),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: const Text("My Account"),
        backgroundColor: widget.isDarkMode ? Colors.grey[900] : Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text("Verify Password First",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.black)),
            const SizedBox(height: 20),
            _buildInputField(
              label: "Current Password",
              controller: currentPasswordController,
              icon: Icons.lock_outline,
              obscure: true,
              onChanged: _verifyPassword,
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 30),
            _buildInputField(
              label: "New Email",
              controller: newEmailController,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              enabled: passwordVerified,
            ),
            const SizedBox(height: 15),
            _buildInputField(
              label: "New Password (leave blank to keep current)",
              controller: newPasswordController,
              icon: Icons.lock,
              obscure: true,
              enabled: passwordVerified,
            ),
            const SizedBox(height: 15),
            _buildInputField(
              label: "Phone Number",
              controller: phoneController,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              enabled: passwordVerified,
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: passwordVerified ? _saveChanges : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    widget.isDarkMode ? Colors.greenAccent[400] : Colors.blue,
                foregroundColor:
                    widget.isDarkMode ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.save),
              label: const Text("Save Changes",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            if (showSuccessMessage)
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      widget.isDarkMode ? Colors.green[900] : Colors.green[50],
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text("Account updated successfully.",
                          style: TextStyle(
                              color: widget.isDarkMode
                                  ? Colors.white
                                  : Colors.green[800])),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
