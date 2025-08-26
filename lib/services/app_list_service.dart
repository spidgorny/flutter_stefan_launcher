import 'package:DETOXD/services/blacklist.dart';
import 'package:appcheck/appcheck.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      // 'apps': apps,
      // 'blackList': _largePackageBlacklist,
    });

    debugPrintX('getApplications done: ${processedApps.length} apps');
    var oneApp = processedApps.where(
      (AppInfo app) => app.appName!.toLowerCase().contains('camera'),
    );

    for (var app in oneApp) {
      debugPrintX('Found camera app: ${app.appName} (${app.packageName})');
    }
    isLoading = false;
    applications = processedApps;
  }

  // This function will be executed in a separate isolate
  static Future<List<AppInfo>> _fetchAndProcessApps(
    Map<String, dynamic> args,
  ) async {
    RootIsolateToken rootIsolateToken = args['rootIsolateToken'];
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    final appCheck = AppCheck();
    var apps = await appCheck.getInstalledApps();
    // List<AppInfo>? apps = args['apps'];
    // debugPrintX is not available in isolate, use debugPrint directly if needed
    debugPrint('Isolate: getInstalledApps');
    debugPrint('Isolate: installed apps: ${apps?.length}');

    if (apps == null || apps.isEmpty) {
      return [];
    }

    // Find the badIconApp within the isolate if necessary, or pass its details
    AppInfo? badIconApp;
    try {
      badIconApp = apps.firstWhere(
        (AppInfo app) => app.packageName == 'com.android.htmlviewer',
      );
    } catch (e) {
      // Handle case where badIconApp is not found, if necessary
      debugPrint('Isolate: com.android.htmlviewer not found.');
    }

    apps = apps.where((AppInfo app) {
      if (badIconApp != null &&
          app.icon != null &&
          badIconApp.icon != null &&
          foundation.listEquals(app.icon, badIconApp.icon)) {
        return false;
      }
      return true;
    }).toList();

    return apps;
  }

  List<AppInfo> filterBlacklistedApps(List<AppInfo> apps) {
    apps = apps.where((AppInfo app) {
      bool isBlacklisted = _largePackageBlacklist.any(
        (String x) => app.packageName.startsWith(x),
      );
      return !isBlacklisted;
    }).toList();

    apps.sort(
      (a, b) => (a.appName ?? "").toLowerCase().compareTo(
        (b.appName ?? "").toLowerCase(),
      ),
    );
    return apps;
  }
}
