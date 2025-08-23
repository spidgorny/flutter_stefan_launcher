import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:watch_it/watch_it.dart';

import '../../data/data_repo.dart';
import '../../data/my_app_info.dart';
import '../../data/settings.dart';
import '../../main.dart';
import '../../service/app_list_service.dart';
import '../../swipable.dart';
import 'modal_fit.dart';

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
    final settings = watch(di<Settings>());

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
            color: settings.isDarkMode ? Colors.white : Colors.black,
            onPressed: () {
              // Navigator.pop(context);
              SwipeableScaffold.of(context)?.scrollBackToCenter();
            },
            icon: const Icon(Icons.arrow_back),
          ),

          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 18),
              //  ${appListService.applications.length}
              border: InputBorder.none,
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(Icons.clear),
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

class ListTileSmall extends StatelessWidget {
  final Widget title;
  final Widget trailing;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;
  const ListTileSmall({
    super.key,
    required this.title,
    required this.trailing,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
              child: trailing,
            ),
            title,
          ],
        ),
      ),
    );
  }
}

class ListItemWithoutIcon extends StatelessWidget with WatchItMixin {
  AppInfo app;
  ListItemWithoutIcon(this.app);
  final AppCheck appCheck = AppCheck();

  @override
  Widget build(BuildContext context) {
    final dataRepo = watch(di<DataRepo>());
    final settings = watch(di<Settings>());

    var myAppInfo = MyAppInfo(
      app: app,
      isFav: dataRepo.favorites.any(
        (MyAppInfo x) => x.app.packageName == app.packageName,
      ),
    );

    return ListTileSmall(
      // dense: true,
      // visualDensity: VisualDensity.compact,
      onTap: () {
        appCheck.launchApp(app.packageName);
      },
      title: Text(
        app.appName!,
        style: TextStyle(
          fontSize: 25,
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
          color: settings.isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      trailing: myAppInfo.isFav
          ? IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => dataRepo.toggleFavorite(app),
              icon: Icon(Icons.star, color: Colors.yellow),
            )
          : IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => dataRepo.toggleFavorite(app),
              icon: Icon(
                Icons.star_border,
                color: settings.isDarkMode ? Colors.white : Colors.black38,
              ),
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
