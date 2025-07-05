import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:watch_it/watch_it.dart';

import '../../data/settings.dart';
import '../../main.dart';

class SettingsPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool useNotificationDotOnAppIcon = true;

  @override
  Widget build(BuildContext context) {
    final settings = watch(di<Settings>());
    final themeNotifier = watch(di<ThemeNotifier>());
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SettingsList(
        platform: DevicePlatform.android,
        sections: [
          SettingsSection(
            title: Text('General'),
            tiles: [
              SettingsTile(
                title: Text('Set as default launcher'),
                description: Text('Swipe up will open DETOXD'),
                trailing: Icon(Icons.home),
              ),
              SettingsTile(
                title: Text('Share DETOXD (please)'),
                trailing: Icon(Icons.share),
                onPressed: (BuildContext context) {
                  SharePlus.instance.share(
                    ShareParams(
                      text: 'https://playstore.google.com',
                      subject: 'Awesome app',
                    ),
                  );
                },
              ),
              // SettingsTile(
              //   title: Text('Edit favorites'),
              //   trailing: Icon(Icons.star),
              //   onPressed: (BuildContext context) => {
              //     GoRouter.of(context).push('/config'),
              //   },
              // ),
              SettingsTile.switchTile(
                initialValue: settings.isInfinityScroll,
                onToggle: (value) {
                  setState(() {
                    settings.isInfinityScroll = value;
                  });
                },
                title: Text('Infinity scroll'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Design'),
            tiles: [
              SettingsTile.switchTile(
                initialValue: settings.isDarkMode,
                onToggle: (value) {
                  settings.isDarkMode = value;
                  themeNotifier.toggleTheme(!themeNotifier.isDarkMode);
                },
                title: Text('Dark Mode'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
