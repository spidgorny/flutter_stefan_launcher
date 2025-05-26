import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

class Settings with ChangeNotifier {
  late final SharedPreferencesWithCache _asyncPrefs;

  Settings() {
    debugPrint('Settings init');
    init();
  }

  Future<void> init() async {
    await initSharedPrefs();
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
}
