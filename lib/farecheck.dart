import 'package:flutter/material.dart';

class FareCheckPage extends StatefulWidget {
  final bool isDarkMode;
  const FareCheckPage({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  _FareCheckPageState createState() => _FareCheckPageState();
}

class _FareCheckPageState extends State<FareCheckPage> {
  final List<String> stations = [
    'Fernando Poe jr.',
    'Roosevelt',
    'Balintawak',
    'Monumento',
    '5th Avenue',
    'R. Papa',
    'Abad Santos',
    'Blumentritt',
    'Tayuman',
    'Bambang',
    'D. Jose',
    'Carriedo',
    'Central Terminal',
    'UN Avenue',
    'Pedro Gil',
    'Quirino',
    'Vito Cruz',
    'Gil Puyat',
    'Libertad',
    'EDSA',
    'Baclaran',
    'Redemptorist',
    'MIA',
    'PITX',
    'Ninoy Aquino Ave.',
    'D. Santos',
  ];

  final List<String> passengerTypes = ['Regular', 'Senior Citizen', 'PWD'];
  final List<String> ticketTypes = ['Single Journey Ticket', 'Beep Card'];

  String? selectedFrom;
  String? selectedTo;
  String selectedPassengerType = 'Regular';
  String selectedTicketType = 'Single Journey Ticket';
  double? fare;

  void computeFare() {
    if (selectedFrom != null && selectedTo != null) {
      int start = stations.indexOf(selectedFrom!);
      int end = stations.indexOf(selectedTo!);
      int numStations = (end - start).abs();

      
      Map<int, double> fareMatrixSingleJourney = {
        1: 15.00, // 1-2 stations
        2: 15.00, // 1-2 stations
        3: 20.00, // 3-4 stations
        4: 20.00, // 3-4 stations
        5: 25.00, // 5-6 stations
        6: 25.00, // 5-6 stations
        7: 30.00, // 7-8 stations
        8: 30.00, // 7-8 stations
        9: 35.00, // 9-10 stations
        10: 35.00, // 9-10 stations
        11: 40.00, // 11+ stations
      };

      
      Map<int, double> fareMatrixBeepCard = {
        1: 14.00, // 1-2 stations
        2: 14.00, // 1-2 stations
        3: 18.00, // 3-4 stations
        4: 18.00, // 3-4 stations
        5: 22.00, // 5-6 stations
        6: 22.00, // 5-6 stations
        7: 27.00, // 7-8 stations
        8: 27.00, // 7-8 stations
        9: 32.00, // 9-10 stations
        10: 32.00, // 9-10 stations
        11: 36.00, // 11+ stations
      };

      Map<int, double> fareMatrix =
          selectedTicketType == 'Single Journey Ticket'
              ? fareMatrixSingleJourney
              : fareMatrixBeepCard;

      
      double baseFare = fareMatrix[numStations] ??
          40.00; 

      
      if (selectedPassengerType == 'Senior Citizen' ||
          selectedPassengerType == 'PWD') {
        baseFare *= 0.8; 
      }

      setState(() {
        fare = baseFare;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final boxColor = isDark ? Colors.grey[900] : Colors.grey[100];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.green,
        title: Text(
          "Fare Checker",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: textColor),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                )
            ],
          ),
          padding: EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "LRT-1 Fare Estimator",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 40),
              buildDropdown(
                label: "Passenger Type",
                value: selectedPassengerType,
                items: passengerTypes,
                onChanged: (value) {
                  setState(() => selectedPassengerType = value!);
                  computeFare();
                },
                textColor: textColor,
                icon: Icons.person,
              ),
              SizedBox(height: 20),
              buildDropdown(
                label: "Ticket Type",
                value: selectedTicketType,
                items: ticketTypes,
                onChanged: (value) {
                  setState(() => selectedTicketType = value!);
                  computeFare();
                },
                textColor: textColor,
                icon: Icons.card_travel,
              ),
              SizedBox(height: 20),
              buildDropdown(
                label: "From Station",
                value: selectedFrom,
                items: stations,
                onChanged: (value) {
                  setState(() => selectedFrom = value);
                  computeFare();
                },
                textColor: textColor,
                icon: Icons.location_on,
              ),
              SizedBox(height: 20),
              buildDropdown(
                label: "To Station",
                value: selectedTo,
                items: stations,
                onChanged: (value) {
                  setState(() => selectedTo = value);
                  computeFare();
                },
                textColor: textColor,
                icon: Icons.location_on,
              ),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? Colors.green.shade800 : Colors.green.shade400,
                      isDark ? Colors.green.shade700 : Colors.green.shade200,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: fare != null
                      ? Text(
                          "Fare: ₱${fare!.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.greenAccent : Colors.green[900],
                          ),
                        )
                      : Text(
                          "Select stations to see fare.",
                          style: TextStyle(
                              color: textColor.withOpacity(0.7), fontSize: 20),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required dynamic value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required Color textColor,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor, fontSize: 18),
        prefixIcon: Icon(icon, color: textColor),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: textColor.withOpacity(0.5)),
        ),
        border: OutlineInputBorder(),
      ),
      dropdownColor: widget.isDarkMode ? Colors.grey[850] : null,
      style: TextStyle(color: textColor, fontSize: 18),
      iconEnabledColor: textColor,
      items: items.map((String val) {
        return DropdownMenuItem<String>(
          value: val,
          child: Text(val, style: TextStyle(color: textColor, fontSize: 18)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
