import 'package:DETOXD/services/app_list_service.dart';
import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../data/data_repo.dart';
import '../../data/my_app_info.dart';
import '../../data/platform_service.dart';
import '../../services/app_report_service.dart';

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
                style: TextStyle(fontSize: 24),
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
              title: Text('App Info'),
              leading: Icon(Icons.info),
              onTap: () {
                var service = MyPlatformService();
                service.openAppInfo(app.app.packageName);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text('Rename App'),
              leading: Icon(Icons.edit),
              onTap: () => _showRenameDialog(context),
            ),
            ListTile(
              title: Text('Remove App'),
              leading: Icon(Icons.delete),
              onTap: () => _showRemoveDialog(context),
            ),
            ListTile(
              title: Text('Report App'),
              leading: Icon(Icons.report),
              onTap: () => _showReportDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRemoveDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove App'),
        content: Text('Are you sure you want to remove this app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              di<DataRepo>().removeApp(app.app.packageName);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context) async {
    final textController = TextEditingController(text: app.app.appName);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename App'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              di<DataRepo>().renameApp(
                app.app.packageName,
                textController.text,
              );
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
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

  Future<void> _showReportDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report App'),
        content: Text('Do you want to report this app to the server?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _reportApp(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Report'),
          ),
        ],
      ),
    );
  }

  Future<void> _reportApp(BuildContext context) async {
    try {
      final reportService = di<AppReportService>();
      final appList = di<AppListService>();

      await reportService.reportApp(
        packageName: app.app.packageName,
        appName: app.app.appName ?? 'Unknown',
      );

      appList.addToBlacklist(app.app.packageName);

      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("App reported successfully")));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to report app: $e")));
      debugPrint("Error reporting app: $e");
    }
  }
}
