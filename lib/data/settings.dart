import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

class Settings with ChangeNotifier {
  late final SharedPreferencesWithCache _asyncPrefs;
  bool isReady = false;

  Settings() {
    debugPrint('Settings init');
    init();
  }

  Future<void> init() async {
    await initSharedPrefs();
    isReady = true;
  }

  Future<void> initSharedPrefs() async {
    const SharedPreferencesAsyncAndroidOptions options =
        SharedPreferencesAsyncAndroidOptions(
          backend: SharedPreferencesAndroidBackendLibrary.SharedPreferences,
          originalSharedPreferencesOptions:
              AndroidSharedPreferencesStoreOptions(fileName: 'settings'),
        );
    debugPrint('Settings init shared prefs');
    _asyncPrefs = await SharedPreferencesWithCache.create(
      sharedPreferencesOptions: options,
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    debugPrint('Settings init shared prefs done');
  }

  bool get isInfinityScroll => _asyncPrefs.getBool('isInfinityScroll') ?? false;
  set isInfinityScroll(bool value) =>
      _asyncPrefs.setBool('isInfinityScroll', value);

  bool get isDarkMode => _asyncPrefs.getBool('isDarkMode') ?? false;
  set isDarkMode(bool value) => _asyncPrefs.setBool('isDarkMode', value);

  bool get isStatusBar => _asyncPrefs.getBool('isStatusBar') ?? false;
  set isStatusBar(bool value) => _asyncPrefs.setBool('isStatusBar', value);
}
