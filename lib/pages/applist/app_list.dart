import 'package:appcheck/appcheck.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../data/data_repo.dart';
import '../../data/my_app_info.dart';
import 'list_item.dart';

class AppList extends StatefulWidget with WatchItStatefulWidgetMixin {
  const AppList({super.key});

  @override
  State<AppList> createState() => _AppListState();
}

class _AppListState extends State<AppList> {
  final appCheck = AppCheck();
  List<AppInfo> applications = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    debugPrint('init state');
    super.initState();
    getApplications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void getApplications() async {
    var apps = await appCheck.getInstalledApps();
    apps = apps?.where((app) => !(app.isSystemApp ?? false)).toList();
    // apps = apps
    //     ?.where(
    //       (app) =>
    //           // !(app.packageName.startsWith('com.google.android')) &&
    //           !(app.packageName.startsWith('com.google.internal')) &&
    //           !(app.packageName.startsWith('com.oplus')) &&
    //           !(app.packageName.startsWith('com.android')),
    //     )
    //     .toList();
    apps?.sort(
      (a, b) => a.appName!.toLowerCase().compareTo(b.appName!.toLowerCase()),
    );

    if (!kIsWeb && !kDebugMode) {
      await Future.delayed(const Duration(seconds: 2));
    }

    setState(() {
      applications = apps ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataRepo = watch(di<DataRepo>());
    var nonFavApps = applications
        .where(
          (app) => !(dataRepo.favorites.any(
            (MyAppInfo x) => x.app.packageName == app.packageName,
          )),
        )
        .toList();
    debugPrint('search: ${_searchController.text}');
    if (_searchController.text != '') {
      nonFavApps = nonFavApps
          .where(
            (app) => app.appName!.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search...',
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.text,
            onChanged: (value) {
              setState(() {}); // typing should trigger widget refresh
            },
            cursorColor: Colors.black,
          ),
          // surfaceTintColor: Colors.white30,
          // backgroundColor: Colors.amber,
          foregroundColor: Colors.blueAccent,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings,
              ), // Replace with your desired icon
              onPressed: () {
                for (var info in dataRepo.appUsageInfo) {
                  debugPrint(info.toString());
                }
              },
            ),

            // FilledButton(
            //   onPressed: () {
            //     debugPrint("Fav len: ${dataRepo.favorites.length}");
            //     dataRepo.loadFavorites();
            //   },
            //   child: Icon(Icons.settings),
            // ),
          ],
        ),
      ),
      body: dataRepo.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: dataRepo.favorites.length + nonFavApps.length,
                itemBuilder: (context, index) {
                  final app = index < dataRepo.favorites.length
                      ? dataRepo.favorites[index]
                      : MyAppInfo(
                          app: nonFavApps[index - dataRepo.favorites.length],
                        );
                  return ListItemForApp(app, (app) {
                    dataRepo.toggleFavorite(app);
                    setState(() {});
                  });
                },
              ),
            ),
      // bottomNavigationBar: BottomButtons(appCheck: appCheck),
    );
  }
}
