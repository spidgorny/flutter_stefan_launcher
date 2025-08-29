import 'package:DETOXD/services/app_list_service.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../data/data_repo.dart';
import '../../data/my_app_info.dart';
import '../../main.dart';
import 'list_item.dart';

/// @deprecated - not used anymore
/// @see all_apps_launcher.dart
class AppList extends StatefulWidget with WatchItStatefulWidgetMixin {
  const AppList({super.key});

  @override
  State<AppList> createState() => _AppListState();
}

class _AppListState extends State<AppList> {
  var startTime = DateTime.now();
  final TextEditingController _searchController = TextEditingController();

  debugPrintX(String message) {
    debugPrint('${DateTime.now().difference(startTime)} $message');
    startTime = DateTime.now();
  }

  @override
  void initState() {
    super.initState(); // Call super.initState() first
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrintX('build');
    var appListService = getIt<AppListService>();

    final dataRepo = watch(di<DataRepo>());
    // var nonFavApps = applications
    //     .where(
    //       (app) => !(dataRepo.favorites.any(
    //         (MyAppInfo x) => x.app.packageName == app.packageName,
    //       )),
    //     )
    //     .toList();
    // debugPrint('search: ${_searchController.text}');
    // if (_searchController.text != '') {
    //   nonFavApps = nonFavApps
    //       .where(
    //         (app) => app.appName!.toLowerCase().contains(
    //           _searchController.text.toLowerCase(),
    //         ),
    //       )
    //       .toList();
    // }

    Widget x = Scaffold(
      // backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search ${appListService.applications.length} apps...',
              border: InputBorder.none,
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).focusColor,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    ),
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
            PopupMenuButton<String>(
              onSelected: (String result) {
                // Handle the selected item
                if (result == 'debug-usage-info') {
                  for (var info in dataRepo.appUsageInfo) {
                    debugPrintX(info.toString());
                  }
                }
                if (result == 'refresh') {
                  appListService.getApplications();
                }
                // Add more cases for other menu items if needed
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'debug-usage-info',
                  child: Row(
                    children: [
                      Icon(Icons.settings), // Added color to the icon
                      SizedBox(width: 8), // Added spacing
                      Text('Debug Usage Info'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh), // Added color to the icon
                      SizedBox(width: 8), // Added spacing
                      Text('Refresh App List'),
                    ],
                  ),
                ),
                // Add more PopupMenuItem for other options
              ],
              icon: const Icon(Icons.more_vert), // Three dots icon
            ),
            // FilledButton(
            //   onPressed: () {
            //     debugPrint("Fav len: ${dataRepo.favorites.length}");
            //     dataRepo.loadFavorites();
            //   },
            //   child: const Icon(Icons.settings),
            // ),
          ],
        ),
      ),
      body: dataRepo.isLoading || appListService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: appListService.applications.length,
                itemBuilder: (context, index) {
                  final app = appListService.applications[index];
                  return ListItemForApp(
                    MyAppInfo(
                      app: app,
                      isFav: dataRepo.favorites.any(
                        (MyAppInfo x) => x.app.packageName == app.packageName,
                      ),
                    ),
                    (app) {
                      dataRepo.toggleFavorite(app);
                      setState(() {});
                    },
                  );
                },
              ),
            ),
      // bottomNavigationBar: BottomButtons(appCheck: appCheck),
    );
    debugPrintX('build done');
    return x;
  }
}
