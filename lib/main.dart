import 'package:appcheck/appcheck.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
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
  final ScrollController _scrollController =
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
    // apps = apps?.where((app) => !(app.isSystemApp ?? false)).toList();
    apps = apps
        ?.where(
          (app) =>
              // !(app.packageName.startsWith('com.google.android')) &&
              !(app.packageName.startsWith('com.google.internal')) &&
              !(app.packageName.startsWith('com.android')),
        )
        .toList();
    apps?.sort(
      (a, b) => a.appName!.toLowerCase().compareTo(b.appName!.toLowerCase()),
    );

    setState(() {
      applications = apps ?? [];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _previousScrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void initState() {
    debugPrint('init state');
    super.initState();
    getApplications();
    loadTickSound();
    _scrollController.addListener(_onScroll); // Add the listener
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the controller
    super.dispose();
  }

  void _onScroll() {
    // Get the current scroll offset
    double currentScrollOffset = _scrollController.offset;

    // Check if the user is scrolling and if the scroll direction is bringing
    // new content into view.
    // We check if the list is not at the extreme ends to avoid triggering
    // the event when overscrolling.
    if (_scrollController.position.userScrollDirection !=
            ScrollDirection.idle &&
        !_scrollController.position.atEdge) {
      var diff = (currentScrollOffset - _previousScrollOffset).abs();
      if (diff > 32) {
        debugPrint('play');
        soundPlayer.play(soundId);
      }
    }

    // Update the previous scroll offset for the next scroll event
    _previousScrollOffset = currentScrollOffset;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        controller: _scrollController, // Attach the controller
        padding: const EdgeInsets.all(16),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final app = applications[index];
          return ListTile(
            title: Text(app.appName ?? app.packageName),
            leading: app.icon != null ? Image.memory(app.icon!) : null,
            subtitle: Text(app.packageName),
            onTap: () => _launchApp(app),
          );
        },
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
