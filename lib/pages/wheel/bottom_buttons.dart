import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';

class BottomButtons extends StatelessWidget {
  const BottomButtons({super.key, required this.appCheck});

  final AppCheck appCheck;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      // color: Colors.blueAccent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.phone, size: 48, color: Colors.white),
            tooltip: 'phone',
            onPressed: () {
              appCheck.launchApp('com.google.android.dialer');
            },
          ),
          IconButton(
            icon: Icon(Icons.web, size: 48, color: Colors.white),
            tooltip: 'web',
            onPressed: () {
              appCheck.launchApp('com.android.chrome');
            },
          ),
          IconButton(
            icon: Icon(Icons.photo, size: 48, color: Colors.white),
            tooltip: 'photo',
            onPressed: () {
              appCheck.launchApp('com.google.android.apps.photos');
            },
          ),
          IconButton(
            icon: Icon(Icons.camera, size: 48, color: Colors.white),
            tooltip: 'camera',
            onPressed: () {
              appCheck.launchApp('com.android.camera2');
            },
          ),
        ],
      ),
    );
  }
}
