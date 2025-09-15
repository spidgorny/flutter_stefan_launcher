import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:watch_it/watch_it.dart';

import '../../data/settings.dart'; // For date formatting

class LiveTimeWidget extends StatefulWidget with WatchItStatefulWidgetMixin {
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
  var battery = Battery();
  var batteryLevel = 0;
  BatteryState batteryState = BatteryState.unknown;
  StreamSubscription<BatteryState>? _batteryStateSubscription;

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

    initBatteryLevel();
  }

  void initBatteryLevel() async {
    var level = await battery.batteryLevel;
    debugPrint('Battery Level: $batteryLevel');
    setState(() {
      batteryLevel = level;
    });
    if (_batteryStateSubscription == null) {
      return;
    }
    _batteryStateSubscription = battery.onBatteryStateChanged.listen((
      BatteryState state,
    ) {
      setState(() {
        batteryState = state;
      });
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
    final settings = watch(di<Settings>());
    // Format the current time to HH:mm:ss using the intl package
    String formattedTime = DateFormat('HH:mm').format(_currentTime);

    // Display the formatted time in a Text widget
    var iconForBattery = Icons.battery_1_bar;
    if (batteryLevel > 16.5 && batteryLevel < 33) {
      iconForBattery = Icons.battery_2_bar;
    }
    if (batteryLevel > 33 && batteryLevel < 50) {
      iconForBattery = Icons.battery_3_bar;
    }
    if (batteryLevel > 50 && batteryLevel < 66.5) {
      iconForBattery = Icons.battery_4_bar;
    }
    if (batteryLevel > 66.5 && batteryLevel < 82.5) {
      iconForBattery = Icons.battery_5_bar;
    }
    if (batteryLevel > 82.5 && batteryLevel < 99) {
      iconForBattery = Icons.battery_6_bar;
    }
    if (batteryLevel > 99) {
      iconForBattery = Icons.battery_full;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          formattedTime,
          style: GoogleFonts.inter(
            fontSize: 48, // Larger font size for visibility
            fontWeight: FontWeight.bold,
            // color: Colors.white, // White text color
            shadows: settings.isDarkMode
                ? const <Shadow>[
                    // Adding text shadow for better readability
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(150, 0, 0, 0),
                    ),
                  ]
                : const [],
          ),
        ),
        Text(
          DateFormat('EEEE, dd MMM').format(_currentTime),
          style: GoogleFonts.inter(
            fontSize: 18, // Larger font size for visibility
            fontWeight: FontWeight.bold,
            // color: Colors.white, // White text color
            shadows: settings.isDarkMode
                ? const <Shadow>[
                    // Adding text shadow for better readability
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 5.0,
                      color: Color.fromARGB(150, 0, 0, 0),
                    ),
                  ]
                : const [],
          ),
        ),
        GestureDetector(
          onTap: () {
            initBatteryLevel();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                ?batteryState == BatteryState.charging
                    ? Icon(
                        Icons.power,
                        // color: Colors.white
                      )
                    : null,
                Icon(
                  iconForBattery,
                  size: 18, // color: Colors.white
                ),
                ?batteryLevel > 0
                    ? Text(
                        '$batteryLevel%',
                        style: GoogleFonts.inter(
                          // fontSize: 15.0,
                          fontWeight: FontWeight.w800,
                          // color: Colors.white,
                          shadows: settings.isDarkMode
                              ? <Shadow>[
                                  // Adding text shadow for better readability
                                  Shadow(
                                    offset: Offset(2.0, 2.0),
                                    blurRadius: 5.0,
                                    color: Color.fromARGB(150, 0, 0, 0),
                                  ),
                                ]
                              : [],
                        ),
                      )
                    : null,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
