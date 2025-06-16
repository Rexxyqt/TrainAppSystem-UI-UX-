import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class RouteMapPage extends StatefulWidget {
  final bool isDarkMode;

  const RouteMapPage({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  _RouteMapPageState createState() => _RouteMapPageState();
}

class _RouteMapPageState extends State<RouteMapPage> {
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
    {
      "label": "Normal",
      "description": "Smooth passenger flow",
      "color": Colors.green,
      "icon": Icons.check_circle
    },
    {
      "label": "Moderate",
      "description": "Moderate crowd",
      "color": Colors.orange,
      "icon": Icons.group
    },
    {
      "label": "High",
      "description": "Crowded",
      "color": Colors.deepOrange,
      "icon": Icons.warning
    },
    {
      "label": "Severe",
      "description": "Severely crowded",
      "color": Colors.red,
      "icon": Icons.error
    },
  ];

  late List<Map<String, dynamic>> crowdStatuses;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _generateStatuses();
    _timer = Timer.periodic(Duration(seconds: 10), (_) => _generateStatuses());
  }

  void _generateStatuses() {
    final random = Random();
    setState(() {
      crowdStatuses = List.generate(
        stations.length,
        (_) => statuses[random.nextInt(statuses.length)],
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final currentStationIndex = stations.indexOf("Monumento");

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'LRT Route Map',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: crowdStatuses.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: stations.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) return _buildLegend(isDark);
                  final i = index - 1;
                  return _buildStationTile(
                    station: stations[i],
                    status: crowdStatuses[i],
                    isDark: isDark,
                    isLast: i == stations.length - 1,
                    isCurrent: i == currentStationIndex,
                  );
                },
              ),
            ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        children: statuses.map((status) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(status['icon'], color: status['color'], size: 20),
              const SizedBox(width: 6),
              Text(
                status['label'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStationTile({
    required String station,
    required Map<String, dynamic> status,
    required bool isDark,
    required bool isLast,
    required bool isCurrent,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  isCurrent ? Icons.my_location : status['icon'],
                  color: isCurrent ? Colors.blueAccent : status['color'],
                  size: 28,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: Colors.grey.shade400,
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? Colors.blueAccent.withOpacity(0.1)
                      : isDark
                          ? Colors.grey[850]
                          : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          station,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.navigation,
                                    size: 16, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'You are here',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status['description'],
                      style: TextStyle(
                        fontSize: 15,
                        color: status['color'],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
