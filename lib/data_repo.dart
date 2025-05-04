import 'dart:convert';

import 'package:appcheck/appcheck.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

import 'MyAppInfo.dart';

class DataRepo with ChangeNotifier {
  late final SharedPreferencesWithCache _asyncPrefs;
  List<MyAppInfo> favorites = [];

  DataRepo() {
    debugPrint('DataRepo init');
    init();
  }

  Future<void> init() async {
    await initSharedPrefs();
    await loadFavorites();
    notifyListeners();
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
}
