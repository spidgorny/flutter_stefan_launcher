import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:watch_it/watch_it.dart';

import '../data/data_repo.dart';
import '../data/my_app_info.dart';
import '../main.dart';
import '../service/app_list_service.dart';
import '../swipable.dart';
import 'applist/modal_fit.dart';

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
          leading: IconButton(
            onPressed: () {
              // Navigator.pop(context);
              SwipeableScaffold.of(context)?.scrollBackToCenter();
            },
            icon: const Icon(Icons.arrow_back),
          ),

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
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
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

class ListItemWithoutIcon extends StatelessWidget with WatchItMixin {
  AppInfo app;
  ListItemWithoutIcon(this.app);
  final AppCheck appCheck = AppCheck();

  @override
  Widget build(BuildContext context) {
    final dataRepo = watch(di<DataRepo>());

    var myAppInfo = MyAppInfo(
      app: app,
      isFav: dataRepo.favorites.any(
        (MyAppInfo x) => x.app.packageName == app.packageName,
      ),
    );

    return ListTile(
      onTap: () {
        appCheck.launchApp(app.packageName);
      },
      title: Text(
        app.appName!,
        style: const TextStyle(
          fontSize: 25,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      trailing: myAppInfo.isFav
          ? IconButton(
              onPressed: () => dataRepo.toggleFavorite(app),
              icon: Icon(Icons.star, color: Colors.yellow),
            )
          : IconButton(
              onPressed: () => dataRepo.toggleFavorite(app),
              icon: Icon(Icons.star_border, color: Colors.black38),
            ),
      onLongPress: () async {
        String action = await showMaterialModalBottomSheet(
          expand: false,
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => ModalFit(app: myAppInfo),
        );
        if (action == ModalFit.ADD_TO_FAVORITES) {
          dataRepo.toggleFavorite(app);
        }
      },
    );
  }
}
