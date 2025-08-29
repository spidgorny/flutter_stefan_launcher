import 'package:DETOXD/services/blacklist.dart';
import 'package:appcheck/appcheck.dart'; // For AppInfo
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For MethodChannel & RootIsolateToken

import 'app_report_service.dart';

class AppListService with ChangeNotifier {
  var startTime = DateTime.now();
  bool isLoading = true;
  List<AppInfo> applications = [];
  final AppReportService _appReportService = AppReportService();
  final List<String> _largePackageBlacklist = largePackageBlacklist;

  AppListService() {
    getApplications().then((_) {
      applications = filterBlacklistedApps(applications);
      debugPrintX('getApplications done: ${applications.length} apps');
      notifyListeners();
    });
  }

  /// Adds a package to the blacklist and refreshes the application list
  Future<void> addToBlacklist(String packageName) async {
    if (!_largePackageBlacklist.contains(packageName)) {
      _largePackageBlacklist.add(packageName);
      applications = filterBlacklistedApps(
        applications,
      ); // Refresh the application list
      debugPrint(
        'After adding blacklisted package, number of good apps: ${applications.length}',
      );
      notifyListeners();
    }
  }

  debugPrintX(String message) {
    debugPrint('${DateTime.now().difference(startTime)} $message');
    startTime = DateTime.now();
  }

  Future<void> getApplications() async {
    debugPrintX('getApplications start');
    isLoading = true;
    notifyListeners(); // Notify loading starts

    try {
      // Fetch blacklisted apps from the server and merge with local list
      final remoteBlacklist = await _appReportService.fetchBlacklistedApps();
      debugPrintX(
        'Fetched ${remoteBlacklist.length} blacklisted apps from server',
      );

      // Add unique package names from remote list to our local blacklist
      for (final packageName in remoteBlacklist) {
        if (!_largePackageBlacklist.contains(packageName)) {
          _largePackageBlacklist.add(packageName);
        }
      }
    } catch (e) {
      debugPrintX('Error fetching blacklist: $e');
      // Continue with existing blacklist if fetch fails
    }

    // Run the app fetching and processing in a separate isolate
    var processedApps = await foundation.compute(_fetchAndProcessApps, {
      'rootIsolateToken': RootIsolateToken.instance!,
    });

    debugPrintX('Processed apps in isolate: ${processedApps.length} apps');

    // Apply blacklist filtering after fetching
    applications = filterBlacklistedApps(processedApps);
    debugPrintX('After blacklist filter: ${applications.length} apps');

    var oneApp = applications.where(
      (AppInfo app) => app.appName!.toLowerCase().contains('camera'),
    );

    for (var app in oneApp) {
      debugPrintX('Found camera app: ${app.appName} (${app.packageName})');
    }

    isLoading = false;
    notifyListeners(); // Notify loading finished and data is ready
  }

  // This function will be executed in a separate isolate
  static Future<List<AppInfo>> _fetchAndProcessApps(
    Map<String, dynamic> args,
  ) async {
    RootIsolateToken rootIsolateToken = args['rootIsolateToken'];
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

    const platform = MethodChannel(
      'com.androidfromfrankfurt.flutter_stefan_launcher/my_platform_service',
    );

    debugPrint('Isolate: Calling getInstalledAppsWithoutIcons');

    List<AppInfo> apps = [];
    try {
      final List<dynamic>? platformApps = await platform
          .invokeMethod<List<dynamic>>('getInstalledAppsWithoutIcons');

      debugPrint(
        'Isolate: Received from platform: ${platformApps?.length} apps',
      );

      if (platformApps != null) {
        apps = platformApps.map((appData) {
          final Map<String, dynamic> appMap = Map<String, dynamic>.from(
            appData as Map,
          );
          return AppInfo(
            appName: appMap['app_name'] as String?,
            packageName: appMap['package_name'] as String,
            versionName: appMap['version_name'] as String?,
            versionCode: (appMap['version_code'] as num?)?.toInt(),
            isSystemApp: appMap['system_app'] as bool?,
            icon: null, // Icons are not fetched
          );
        }).toList();
      }
    } catch (e) {
      debugPrint(
        'Isolate: Error invoking platform method or processing apps: $e',
      );
      // Return empty list or rethrow as appropriate for your error handling strategy
    }

    debugPrint('Isolate: Parsed ${apps.length} apps');
    return apps;
  }

  List<AppInfo> filterBlacklistedApps(List<AppInfo> apps) {
    var filteredApps = apps.where((AppInfo app) {
      bool isBlacklisted = _largePackageBlacklist.any(
        (String x) =>
            app.packageName?.startsWith(x) ?? false, // handle null packageName
      );
      return !isBlacklisted;
    }).toList();

    filteredApps.sort(
      (a, b) => (a.appName ?? "").toLowerCase().compareTo(
        (b.appName ?? "").toLowerCase(),
      ),
    );
    return filteredApps;
  }
}
