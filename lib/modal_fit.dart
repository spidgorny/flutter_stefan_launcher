import 'package:flutter/material.dart';

import 'MyAppInfo.dart';

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
            Text(
              app.app.appName ?? app.app.packageName ?? '',
              style: TextStyle(fontSize: 24, color: Colors.black),
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
              title: Text('Uninstall'),
              leading: Icon(Icons.delete),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
