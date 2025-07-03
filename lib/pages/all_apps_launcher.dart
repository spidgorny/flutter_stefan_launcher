import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../data/data_repo.dart';
import '../main.dart';
import '../service/app_list_service.dart';

class AllAppsLauncher extends StatefulWidget with WatchItStatefulWidgetMixin {
  const AllAppsLauncher({super.key});
  @override
  State<AllAppsLauncher> createState() => _AllAppsLauncherState();
}

class _AllAppsLauncherState extends State<AllAppsLauncher> {
  var startTime = DateTime.now();
  final TextEditingController _searchController = TextEditingController();

  debugPrintX(String message) {
    debugPrint('${DateTime.now().difference(startTime)} $message');
    startTime = DateTime.now();
  }

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
    var searchResults = appListService.applications;
    if (_searchController.text != '') {
      searchResults = searchResults
          .where(
            (app) => app.appName!.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    Widget x = Scaffold(
      // backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search ${appListService.applications.length} apps...',
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
        ),
      ),
      body: dataRepo.isLoading || appListService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final app = searchResults[index];
                  return ListItemWithoutIcon(app);
                },
              ),
            ),
      // bottomNavigationBar: BottomButtons(appCheck: appCheck),
    );
    debugPrintX('build done');
    return x;
  }
}

class ListItemWithoutIcon extends StatelessWidget {
  AppInfo app;
  ListItemWithoutIcon(this.app);
  final AppCheck appCheck = AppCheck();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        alignment: Alignment.centerLeft,
        padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
      ),
      onPressed: () {
        appCheck.launchApp(app.packageName);
      },
      child: Text(
        app.appName!,
        style: const TextStyle(
          fontSize: 30,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
