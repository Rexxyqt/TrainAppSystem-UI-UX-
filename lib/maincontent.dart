import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'profile.dart';
import 'routemap.dart';
import 'addcash.dart';
import 'transaction.dart';
import 'farecheck.dart';
import 'load.dart';
import 'support.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainContent(),
    );
  }
}

class MainContent extends StatefulWidget {
  @override
  _MainContentState createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  bool isDarkMode = false;
  double lrtBalance = 0.0;

  List<int> trainTimers = [203, 320, 130, 240];
  List<int> originalTimers = [203, 320, 130, 240];
  Timer? countdownTimer;
  FlutterTts flutterTts = FlutterTts();

  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _loadLrtBalance();
    startCountdown();
    _videoController = VideoPlayerController.asset('assets/images/lrtmap.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(true);
        _videoController.play();
      });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    _videoController.dispose();
    super.dispose();
  }

  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _loadLrtBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lrtBalance = prefs.getDouble('lrt_balance') ?? 0.0;
    });
  }

  void toggleTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = value;
      prefs.setBool('isDarkMode', isDarkMode);
    });
  }

  void startCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        for (int i = 0; i < trainTimers.length; i++) {
          if (trainTimers[i] > 0) {
            trainTimers[i]--;
          } else if (trainTimers[i] == 0) {
            if (i == 0) {
              flutterTts.speak("Train has arrived at Yamaha monumento.");
            }
            trainTimers[i] = -5;
          } else if (trainTimers[i] < 0) {
            trainTimers[i]++;
            if (trainTimers[i] == 0) {
              trainTimers[i] = originalTimers[i];
            }
          }
        }
      });
    });
  }

  String formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Color(0xfff6f8f9),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.33,
                      child: _videoController.value.isInitialized
                          ? InteractiveViewer(
                              panEnabled: true,
                              scaleEnabled: true,
                              minScale: 1.0,
                              maxScale: 5.0,
                              child: Align(
                                alignment: Alignment.topCenter, // Focus sa taas
                                child: AspectRatio(
                                  aspectRatio:
                                      _videoController.value.aspectRatio,
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                    child: SizedBox(
                                      width: _videoController.value.size.width,
                                      height:
                                          _videoController.value.size.height,
                                      child: VideoPlayer(_videoController),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Center(child: CircularProgressIndicator()),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.location_pin,
                              size: 20,
                              color: isDarkMode ? Colors.white : Colors.black),
                          SizedBox(width: 5),
                          Text(
                            'Yamaha Monumento',
                            style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black),
                          ),
                          Spacer(),
                          Text(
                            'Monday March 26',
                            style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 350,
                      decoration: BoxDecoration(
                        color: Color(0xff056d08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${lrtBalance.toStringAsFixed(2)}PHP',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddCashPage(isDarkMode: isDarkMode),
                                    ),
                                  ).then((_) => _loadLrtBalance());
                                },
                                child: Icon(Icons.add_circle_outline,
                                    color: Colors.white, size: 28),
                              ),
                            ],
                          ),
                          Text('Current Balance',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ActionButton(
                            title: 'Fare Checker',
                            iconPath: 'assets/images/fare.png',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FareCheckPage(isDarkMode: isDarkMode),
                                ),
                              );
                            },
                          ),
                          ActionButton(
                            title: 'LRT Route Map',
                            iconPath: 'assets/images/route.png',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RouteMapPage(isDarkMode: isDarkMode),
                                ),
                              );
                            },
                          ),
                          ActionButton(
                            title: 'Load beep',
                            iconPath: 'assets/images/card.png',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoadPage(
                                    isDarkMode: isDarkMode,
                                    onBalanceUpdated: _loadLrtBalance,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 10),
                      child: Column(
                        children: [
                          buildTrainAvailabilityCard(),
                          SizedBox(height: 10),
                          buildCurrentStationCard(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BottomNavBar(isDarkMode: isDarkMode, onThemeToggle: toggleTheme),
          ],
        ),
      ),
    );
  }

  Widget buildTrainAvailabilityCard() {
    return Container(
      width: 350,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'AVAILABLE TRAINS',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black),
          ),
          for (int i = 0; i < trainTimers.length; i++)
            Text(
              'TRAIN ${i + 1}: ${trainTimers[i] <= 0 ? 'ARRIVING' : formatTime(trainTimers[i])} AT ${[
                "UN",
                "PGIL",
                "CENTRAL S",
                "MIA"
              ][i]}',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
        ],
      ),
    );
  }

  Widget buildCurrentStationCard() {
    return Container(
      width: 350,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'CURRENT STATION',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black),
          ),
          Text(
            'YAMAHA MONUMENTO',
            textAlign: TextAlign.center,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          SizedBox(height: 10),
          Text(
            'NEXT TRAIN: ${trainTimers[0] <= 0 ? 'ARRIVING' : formatTime(trainTimers[0])}',
            style: TextStyle(color: Colors.green),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback? onTap;

  const ActionButton({required this.title, required this.iconPath, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xfffcfed9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(12)),
              child: Image.asset(iconPath),
            ),
            SizedBox(height: 5),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeToggle;

  const BottomNavBar({
    Key? key,
    required this.isDarkMode,
    required this.onThemeToggle,
  }) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff02213a),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () {},
            child: BottomNavItem(
                label: 'HOME', assetPath: 'assets/images/home.png'),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    isDarkMode: widget.isDarkMode,
                    onThemeToggle: widget.onThemeToggle,
                  ),
                ),
              );
            },
            child: BottomNavItem(
                label: 'PROFILE', assetPath: 'assets/images/profile.png'),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TransactionsHistoryScreen()),
              );
            },
            child: BottomNavItem(
                label: 'TRANSACTION',
                assetPath: 'assets/images/transaction.png'),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
            },
            child: BottomNavItem(
                label: 'SUPPORT', assetPath: 'assets/images/support.png'),
          ),
        ],
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final String label;
  final String assetPath;

  const BottomNavItem({required this.label, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(assetPath, width: 36, height: 36, color: Colors.white),
        SizedBox(height: 5),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
