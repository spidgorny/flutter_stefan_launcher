import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:watch_it/watch_it.dart';

import '../../data/data_repo.dart';
import '../../data/my_app_info.dart';
import '../../data/settings.dart';
import 'list_tile_small.dart';
import 'modal_fit.dart';

class ListItemWithoutIcon extends StatelessWidget with WatchItMixin {
  final AppInfo app;
  final AppCheck appCheck = AppCheck();
  ListItemWithoutIcon(this.app, {super.key});

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
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
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
        String? action = await showMaterialModalBottomSheet(
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
