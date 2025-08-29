import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:watch_it/watch_it.dart';

import '../../data/data_repo.dart';
import '../../data/my_app_info.dart';
import '../../data/settings.dart';
import '../applist/modal_fit.dart';

class WheelItem extends StatelessWidget with WatchItMixin {
  final MyAppInfo itemData;
  final FontWeight fontWeight;
  var appCheck = AppCheck();

  WheelItem({super.key, required this.itemData, required this.fontWeight});

  @override
  Widget build(BuildContext context) {
    final dataRepo = watch(di<DataRepo>());
    final settings = watch(di<Settings>());

    return GestureDetector(
      onTap: () => _launchApp(context, itemData.app),
      onLongPress: () => _handleLongPress(context, itemData, dataRepo),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Keep the group centered
        mainAxisSize: MainAxisSize.min, // Keep the Row compact
        crossAxisAlignment:
            CrossAxisAlignment.center, // Vertically align text and icon
        children: <Widget>[
          Stack(
            children: <Widget>[
              Text(
                "${itemData.app.appName}",
                style: GoogleFonts.inter(
                  fontSize: 15.0,
                  fontWeight: fontWeight,
                  color: settings.isDarkMode ? Colors.white : Colors.black,
                  shadows: settings.isDarkMode
                      ? <Shadow>[
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 10.0,
                            color: Color.fromARGB(150, 0, 0, 0),
                          ),
                        ]
                      : [],
                ),
              ),
            ],
          ),
        ],
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

  Future<void> _handleLongPress(
    BuildContext context,
    MyAppInfo itemData,
    DataRepo dataRepo,
  ) async {
    String action = await showMaterialModalBottomSheet(
      expand: false,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalFit(app: itemData),
    );
    if (action == ModalFit.ADD_TO_FAVORITES) {
      dataRepo.toggleFavorite(itemData.app);
    }
  }
}
