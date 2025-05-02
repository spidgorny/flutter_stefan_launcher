import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:soundplayer/soundplayer.dart';

import 'modal_fit.dart';

class AppList extends StatefulWidget {
  const AppList({super.key, required this.title});
  final String title;

  @override
  State<AppList> createState() => _AppListState();
}

class _AppListState extends State<AppList> {
  final appCheck = AppCheck();
  final Soundplayer soundPlayer = Soundplayer(16, 1);
  List<AppInfo> applications = [];
  final ScrollController scrollController =
      ScrollController(); // Declare ScrollController
  late int soundId;
  double _previousScrollOffset = 0.0;
  bool isLoading = true;

  void loadTickSound() async {
    debugPrint('Sound player init...');
    soundPlayer.initSoundplayer(16);
    debugPrint('Sound player initialized');
    soundId = await soundPlayer.load("assets/click.wav");
    debugPrint('Sound loaded id=$soundId/**/');
  }

  void getApplications() async {
    var apps = await appCheck.getInstalledApps();
    apps = apps?.where((app) => !(app.isSystemApp ?? false)).toList();
    // apps = apps
    //     ?.where(
    //       (app) =>
    //           // !(app.packageName.startsWith('com.google.android')) &&
    //           !(app.packageName.startsWith('com.google.internal')) &&
    //           !(app.packageName.startsWith('com.oplus')) &&
    //           !(app.packageName.startsWith('com.android')),
    //     )
    //     .toList();
    apps?.sort(
      (a, b) => a.appName!.toLowerCase().compareTo(b.appName!.toLowerCase()),
    );

    setState(() {
      applications = apps ?? [];
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _previousScrollOffset = scrollController.offset;
      });
    });
  }

  @override
  void initState() {
    debugPrint('init state');
    super.initState();
    getApplications();
    loadTickSound();
    scrollController.addListener(_onScroll); // Add the listener
  }

  @override
  void dispose() {
    scrollController.dispose(); // Dispose the controller
    super.dispose();
  }

  void _onScroll() {
    // Get the current scroll offset
    double currentScrollOffset = scrollController.offset;

    // Check if the user is scrolling and if the scroll direction is bringing
    // new content into view.
    // We check if the list is not at the extreme ends to avoid triggering
    // the event when overscrolling.
    if (scrollController.position.userScrollDirection != ScrollDirection.idle &&
        !scrollController.position.atEdge) {
      var diff = (currentScrollOffset - _previousScrollOffset).abs();
      // debugPrint('diff: $diff');
      if (diff > 75) {
        debugPrint('play');
        soundPlayer.play(soundId);
        // Update the previous scroll offset for the next scroll event
        _previousScrollOffset = currentScrollOffset;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('[search]'),
        surfaceTintColor: Colors.white54,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView.builder(
                controller: scrollController, // Attach the controller
                padding: const EdgeInsets.all(16),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final app = applications[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text(app.appName ?? app.packageName),
                      // textColor: Colors.white,
                      titleTextStyle: TextStyle(color: Colors.black),
                      subtitleTextStyle: TextStyle(color: Colors.black38),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      tileColor: Colors.white54,
                      leading: app.icon != null
                          ? Image.memory(app.icon!)
                          : null,
                      subtitle: Text(app.packageName),
                      onTap: () => _launchApp(app),
                      // onLongPress: () => _longPress(context, app),
                      onLongPress: () {
                        showMaterialModalBottomSheet(
                          expand: false,
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => ModalFit(app: app),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }

  Future<void> _launchApp(AppInfo app) async {
    try {
      await appCheck.launchApp(app.packageName);
      debugPrint("${app.appName ?? app.packageName} launched!");
    } catch (e) {
      if (!mounted) return; // Ensure the widget is still in the tree

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${app.appName ?? app.packageName} not found!")),
      );
      debugPrint("Error launching app: $e");
    }
  }
}
