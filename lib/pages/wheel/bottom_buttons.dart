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
            icon: Icon(
              Icons.phone_outlined,
              size: 48,
              // color: Colors.white
            ),
            tooltip: 'phone',
            onPressed: () {
              appCheck.launchApp('com.google.android.dialer');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              size: 48,
              // color: Colors.white
            ),
            tooltip: 'web',
            onPressed: () {
              appCheck.launchApp('com.android.settings');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.photo_outlined,
              size: 48,
              // color: Colors.white
            ),
            tooltip: 'photo',
            onPressed: () {
              appCheck.launchApp('com.google.android.apps.photos');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.photo_camera_outlined,
              size: 48,
              // color: Colors.white
            ),
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
