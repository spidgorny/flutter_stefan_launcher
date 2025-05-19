import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class LiveTimeWidget extends StatefulWidget {
  const LiveTimeWidget({super.key});

  @override
  State<LiveTimeWidget> createState() => _LiveTimeWidgetState();
}

// State class for LiveTimeWidget
class _LiveTimeWidgetState extends State<LiveTimeWidget> {
  // Timer object to update time every second
  Timer? _timer;
  // DateTime object to hold the current time
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initialize current time
    _currentTime = DateTime.now();
    // Start a periodic timer that fires every second
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      // Update the current time and trigger a rebuild of the widget
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is removed from the widget tree
    // to prevent memory leaks
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format the current time to HH:mm:ss using the intl package
    String formattedTime = DateFormat('HH:mm:ss').format(_currentTime);

    // Display the formatted time in a Text widget
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formattedTime,
          style: const TextStyle(
            fontSize: 48, // Larger font size for visibility
            fontWeight: FontWeight.bold,
            color: Colors.white, // White text color
            shadows: <Shadow>[
              // Adding text shadow for better readability
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 3.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
        ),
        Text(
          DateFormat('EEEE, dd MMM').format(_currentTime),
          style: const TextStyle(
            fontSize: 18, // Larger font size for visibility
            fontWeight: FontWeight.bold,
            color: Colors.white, // White text color
            shadows: <Shadow>[
              // Adding text shadow for better readability
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 5.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
