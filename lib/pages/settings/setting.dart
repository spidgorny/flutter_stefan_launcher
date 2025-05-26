import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:watch_it/watch_it.dart';

import '../../data/settings.dart';

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
              ),
              SettingsTile(
                title: Text('Edit favorites'),
                trailing: Icon(Icons.star),
              ),
              SettingsTile.switchTile(
                initialValue: settings.isInfinityScroll,
                onToggle: (value) {
                  setState(() {
                    settings.isInfinityScroll = (value);
                  });
                },
                title: Text('Infinity scroll'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Design'),
            tiles: [
              SettingsTile(
                title: Text('Conservations'),
                description: Text('No priority conservations'),
              ),
              SettingsTile(
                title: Text('Bubbles'),
                description: Text(
                  'On / Conservations can appear as floating icons',
                ),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Privacy'),
            tiles: [
              SettingsTile(
                title: Text('Device & app notifications'),
                description: Text(
                  'Control which apps and devices can read notifications',
                ),
              ),
              SettingsTile(
                title: Text('Notifications on lock screen'),
                description: Text('Show conversations, default, and silent'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('General'),
            tiles: [
              SettingsTile(
                title: Text('Do Not Disturb'),
                description: Text('Off / 1 schedule can turn on automatically'),
              ),
              SettingsTile(title: Text('Wireless emergency alerts')),
              SettingsTile.switchTile(
                initialValue: false,
                onToggle: (_) {},
                title: Text('Hide silent notifications in status bar'),
              ),
              SettingsTile.switchTile(
                initialValue: false,
                onToggle: (_) {},
                title: Text('Allow notification snoozing'),
              ),
              SettingsTile.switchTile(
                initialValue: useNotificationDotOnAppIcon,
                onToggle: (value) {
                  setState(() {
                    useNotificationDotOnAppIcon = value;
                  });
                },
                title: Text('Notification dot on app icon'),
              ),
              SettingsTile.switchTile(
                initialValue: false,
                onToggle: (_) {},
                title: Text('Enable notifications'),
                description: Text('Get suggested actions, replies and more'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
