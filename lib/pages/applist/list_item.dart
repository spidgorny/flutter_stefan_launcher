import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../data/my_app_info.dart';
import 'modal_fit.dart';

class ListItemForApp extends StatelessWidget {
  final MyAppInfo app;
  final void Function(AppInfo) toggleFavorite;
  final appCheck = AppCheck();
  ListItemForApp(this.app, this.toggleFavorite, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(app.app.appName ?? app.app.packageName),
        // textColor: app.isFav ? Colors.black : null,
        // titleTextStyle: TextStyle(color: Colors.black),
        // subtitleTextStyle: TextStyle(color: Colors.black38),
        // shape: RoundedRectangleBorder(
        //   side: BorderSide(color: Colors.blueGrey, width: 0.5),
        //   borderRadius: BorderRadius.circular(10),
        // ),
        // tileColor: app.isFav ? Colors.lightBlue.shade100 : null,
        leading: app.app.icon != null ? Image.memory(app.app.icon!) : null,
        // subtitle: Text(
        //   app.usageTime != null
        //       ? '${app.usageTime.toString().substring(0, 5)} h'
        //       : '[' + app.app.packageName + ']',
        // ),
        trailing: app.isFav
            ? IconButton(
                onPressed: () => toggleFavorite(app.app),
                icon: Icon(Icons.star, color: Colors.yellow),
              )
            : IconButton(
                onPressed: () => toggleFavorite(app.app),
                icon: Icon(Icons.star_border, color: Colors.white54),
              ),
        onTap: () => toggleFavorite(app.app),
        // onTap: () => _launchApp(context, app.app),
        // onLongPress: () => _longPress(context, app),
        onLongPress: () async {
          String action = await showMaterialModalBottomSheet(
            expand: false,
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => ModalFit(app: app),
          );
          if (action == ModalFit.ADD_TO_FAVORITES) {
            toggleFavorite(app.app);
          }
        },
      ),
    );
  }
}
