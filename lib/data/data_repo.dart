import 'dart:convert';

import 'package:DETOXD/data/settings.dart';
import 'package:DETOXD/main.dart';
import 'package:app_usage/app_usage.dart';
import 'package:appcheck/appcheck.dart';
import 'package:collection/collection.dart'; // Required for firstWhereOrNull
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

import 'my_app_info.dart';

class DataRepo with ChangeNotifier {
  late final SharedPreferencesWithCache _asyncPrefs;
  List<MyAppInfo> favorites = [];
  List<AppUsageInfo> appUsageInfo = [];
  bool isLoading = true;

  DataRepo() {
    debugPrint('DataRepo init');
    init();
  }

  Future<void> init() async {
    await initSharedPrefs();
    await loadFavorites();
    isLoading = false;
    notifyListeners();

    var settings = getIt<Settings>();
    if (settings.isAppUsageEnabled) {
      var usage = await getUsageStats();
      injectUsageIntoAppList(usage);
      notifyListeners();
    }
  }

  Future<void> initSharedPrefs() async {
    const SharedPreferencesAsyncAndroidOptions options =
        SharedPreferencesAsyncAndroidOptions(
          backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
          originalSharedPreferencesOptions:
              AndroidSharedPreferencesStoreOptions(
                fileName: 'the_name_of_a_file',
              ),
        );
    debugPrint('init shared prefs');
    _asyncPrefs = await SharedPreferencesWithCache.create(
      sharedPreferencesOptions: options,
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    debugPrint('init shared prefs done');
  }

  Future<void> loadFavorites() async {
    debugPrint('loadFav');
    var json = _asyncPrefs.getStringList('favorites');
    debugPrint('favorites: $json');
    if (json != null) {
      favorites = json.map((e) => MyAppInfo.fromJson(e)).toList();
    }
    if (favorites.length < 2) {
      favorites.add(
        MyAppInfo(
          app: AppInfo(packageName: 'whatsapp', appName: 'WhatsApp'),
        ),
      );
      favorites.add(
        MyAppInfo(
          app: AppInfo(packageName: 'spotify', appName: 'Spotify'),
        ),
      );
      favorites.add(
        MyAppInfo(
          app: AppInfo(packageName: 'com.android.camera2', appName: 'Camera'),
        ),
      );
      favorites.add(
        MyAppInfo(
          app: AppInfo(packageName: 'telegram', appName: 'Telegram'),
        ),
      );
      favorites.add(
        MyAppInfo(
          app: AppInfo(packageName: 'tiktok', appName: 'TikTok'),
        ),
      );
    }
    debugPrint('loadFav done');
  }

  Future<void> saveFavorites() async {
    List<String> json = favorites.map((e) => jsonEncode(e.toJson())).toList();
    if (json.isNotEmpty) {
      return _asyncPrefs.setStringList('favorites', json);
    }
  }

  Future<void> toggleFavorite(AppInfo app) async {
    var isFavorite = favorites.any((e) => e.app.packageName == app.packageName);
    if (isFavorite) {
      favorites.removeWhere((e) => e.app.packageName == app.packageName);
    } else {
      favorites.add(MyAppInfo(app: app, isFav: true));
    }
    notifyListeners();
    await saveFavorites();
  }

  Future<List<AppUsageInfo>> getUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(
        Duration(hours: DateTime.now().hour, minutes: DateTime.now().minute),
      );
      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(
        startDate,
        endDate,
      );
      appUsageInfo = infoList;
      return infoList;
    } on Exception catch (exception) {
      debugPrint(exception as String?);
      return [];
    }
  }

  void injectUsageIntoAppList(List<AppUsageInfo> usage) {
    for (var app in favorites) {
      AppUsageInfo? usageInfo = usage.firstWhereOrNull(
        (element) => element.packageName == app.app.packageName, //allow null
      );
      if (usageInfo != null) {
        app.usageTime = usageInfo.usage;
      }
    }
  }
}
