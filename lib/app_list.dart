import 'package:appcheck/appcheck.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stefan_launcher/main.dart';
import 'package:flutter_stefan_launcher/sound_service.dart';
import 'package:watch_it/watch_it.dart';

import 'MyAppInfo.dart';
import 'data_repo.dart';
import 'list-item.dart';

class AppList extends StatefulWidget with WatchItStatefulWidgetMixin {
  const AppList({super.key});

  @override
  State<AppList> createState() => _AppListState();
}

class _AppListState extends State<AppList> {
  final appCheck = AppCheck();
  List<AppInfo> applications = [];
  final TextEditingController _searchController = TextEditingController();
  final SoundService soundService = getIt<SoundService>();

  @override
  void initState() {
    debugPrint('init state');
    super.initState();
    getApplications();
    soundService.init();
  }

  @override
  void dispose() {
    soundService.dispose(); // Dispose the controller
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        soundService.initScrollPosition();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataRepo = watch(di<DataRepo>());
    var nonFavApps = applications
        .where(
          (app) => !(dataRepo.favorites.any(
            (x) => x.app.packageName == app.packageName,
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
          surfaceTintColor: Colors.white30,
          // backgroundColor: Colors.amber,
          foregroundColor: Colors.red,
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
                controller:
                    soundService.scrollController, // Attach the controller
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
    );
  }
}
