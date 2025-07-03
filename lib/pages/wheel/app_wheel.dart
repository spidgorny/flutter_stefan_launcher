import 'package:DETOXD/pages/wheel/scrollable_favorites_wheel.dart';
import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';
import 'package:r_nav_n_sheet/r_nav_n_sheet.dart';
import 'package:watch_it/watch_it.dart';

import '../../data/settings.dart';
import 'app_grid_sheet.dart';
import 'clock.dart';

class Wheel extends StatefulWidget with WatchItStatefulWidgetMixin {
  const Wheel({super.key});

  @override
  State<Wheel> createState() => _WheelState();
}

class _WheelState extends State<Wheel> {
  AppCheck appCheck = AppCheck();

  @override
  Widget build(BuildContext context) {
    final settings = watch(di<Settings>());

    return Scaffold(
      // backgroundColor: Colors.transparent,
      backgroundColor: settings.isDarkMode ? Colors.black : Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(34, 34, 0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LiveTimeWidget(),
                  // IconButton(
                  //   icon: const Icon(Icons.settings),
                  //   onPressed: () {
                  //     GoRouter.of(context).push('/config');
                  //   },
                  // ),

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
          ),
          Column(
            children: [
              Container(height: 85),
              Expanded(child: ScrollableFavoritesWheel()),

              // children: List.generate(dataRepo.favorites.length, (index) => index)
              //     .map(
              //       (index) => Container(
              //         margin: EdgeInsets.only(left: 20, right: 20),
              //         color: Colors.transparent,
              //         child: Center(
              //           child: Text(
              //             dataRepo.favorites[index].app.appName ?? '',
              //             style: TextStyle(fontSize: 30, color: Colors.white),
              //           ),
              //         ),
              //       ),
              //     )
              //     .toList(),
            ],
          ),
        ],
      ),
      bottomNavigationBar:
          // DraggableScrollableSheet(
          //   initialChildSize: 0.1,
          //   minChildSize: 0.1,
          //   builder: (BuildContext context, ScrollController scrollController) {
          //     return Column(children: [ColoredBox(color: Colors.white10)]);
          //   },
          // ),
          // BottomButtons(appCheck: AppCheck()),
          RNavNSheet(
            sheet: AppGridSheet(),
            items: [
              const RNavItem(icon: Icons.phone, label: "Home"),
              const RNavItem(icon: Icons.web, label: "Search"),
              const RNavItem(icon: Icons.photo, label: "Cart"),
              const RNavItem(icon: Icons.camera, label: "Account"),
            ],
            onTap: (int index) {
              debugPrint("$index tapped");
              var appsByIndex = [
                'com.google.android.dialer',
                'com.android.chrome',
                'com.google.android.apps.photos',
                'com.android.camera2',
              ];
              appCheck.launchApp(appsByIndex[index]);
            },
          ),
    );
  }
}
