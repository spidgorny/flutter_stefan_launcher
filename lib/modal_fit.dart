import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';

class ModalFit extends StatelessWidget {
  final AppInfo app;
  const ModalFit({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              app.appName ?? app.packageName ?? '',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            ListTile(
              title: Text('Edit'),
              leading: Icon(Icons.edit),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: Text('Copy'),
              leading: Icon(Icons.content_copy),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: Text('Cut'),
              leading: Icon(Icons.content_cut),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: Text('Move'),
              leading: Icon(Icons.folder_open),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: Text('Delete'),
              leading: Icon(Icons.delete),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
