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
        // textColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.black),
        subtitleTextStyle: TextStyle(color: Colors.black38),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.shade300, width: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        tileColor: Colors.white54,
        leading: app.app.icon != null ? Image.memory(app.app.icon!) : null,
        subtitle: Text(
          app.usageTime != null
              ? '${app.usageTime.toString().substring(0, 5)} h'
              : app.app.packageName,
        ),
        trailing: app.isFav
            ? IconButton(
                onPressed: () => toggleFavorite(app.app),
                icon: Icon(Icons.star, color: Colors.yellow),
              )
            : IconButton(
                onPressed: () => toggleFavorite(app.app),
                icon: Icon(Icons.star_border, color: Colors.black54),
              ),
        onTap: () => _launchApp(context, app.app),
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

  Future<void> _launchApp(BuildContext context, AppInfo app) async {
    try {
      await appCheck.launchApp(app.packageName);
      debugPrint("${app.appName ?? app.packageName} launched!");
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${app.appName ?? app.packageName} not found!")),
      );
      debugPrint("Error launching app: $e");
    }
  }
}
