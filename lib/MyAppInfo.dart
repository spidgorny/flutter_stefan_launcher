import 'dart:convert';

import 'package:appcheck/appcheck.dart';

class MyAppInfo {
  MyAppInfo({required this.app, this.isFav = false, this.usageTime});
  final AppInfo app;
  bool isFav;
  Duration? usageTime;

  static MyAppInfo fromJson(String source) {
    Map<String, dynamic> json = jsonDecode(source);
    return MyAppInfo(
      app: AppInfo(
        appName: json['app']['appName'],
        packageName: json['app']['packageName'],
        versionName: json['app']['versionName'],
        versionCode: json['app']['versionCode'],
        isSystemApp: json['app']['isSystemApp'],
        icon: json['app']['icon'] != null
            ? base64Decode(json['app']['icon'])
            : null,
      ),
      isFav: json['isFav'],
    );
  }

  Map<String, dynamic> toJson() => {
    'app': {
      'appName': app.appName,
      'packageName': app.packageName,
      'versionName': app.versionName,
      'versionCode': app.versionCode,
      'isSystemApp': app.isSystemApp,
      'icon': app.icon != null ? base64Encode(app.icon!) : null,
    },
    'isFav': isFav,
  };
}
