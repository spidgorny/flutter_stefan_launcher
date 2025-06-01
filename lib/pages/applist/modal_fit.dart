import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';

import '../../data/my_app_info.dart';

class ModalFit extends StatelessWidget {
  static const ADD_TO_FAVORITES = 'Add to Favorites';
  final MyAppInfo app;
  const ModalFit({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                app.app.appName ?? app.app.packageName,
                style: TextStyle(fontSize: 24, color: Colors.black),
              ),
            ),
            ListTile(
              title: Text('Launch'),
              leading: Icon(Icons.open_in_new),
              onTap: () => _launchApp(context, app.app),
            ),
            app.isFav
                ? ListTile(
                    title: Text('Remove from Favorites'),
                    leading: Icon(Icons.star_border),
                    onTap: () => Navigator.of(context).pop(ADD_TO_FAVORITES),
                  )
                : ListTile(
                    title: Text('Add to Favorites'),
                    leading: Icon(Icons.star),
                    onTap: () => Navigator.of(context).pop(ADD_TO_FAVORITES),
                  ),
            ListTile(
              title: Text('Uninstall (TDB)'),
              leading: Icon(Icons.delete),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchApp(BuildContext context, AppInfo app) async {
    try {
      var appCheck = AppCheck();
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
