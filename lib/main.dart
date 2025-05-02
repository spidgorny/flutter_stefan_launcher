import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:soundplayer/soundplayer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final appCheck = AppCheck();
  final Soundplayer soundPlayer = Soundplayer(16, 1);
  List<AppInfo> applications = [];
  final ScrollController scrollController =
      ScrollController(); // Declare ScrollController
  late int soundId;
  double _previousScrollOffset = 0.0;

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
        title: const Text('Launcher Search'),
        surfaceTintColor: Colors.white54,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
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
                  side: BorderSide(color: Colors.grey.shade300, width: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                tileColor: Colors.white54,
                leading: app.icon != null ? Image.memory(app.icon!) : null,
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
