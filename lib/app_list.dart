import 'package:app_usage/app_usage.dart';
import 'package:appcheck/appcheck.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:soundplayer/soundplayer.dart';
import 'package:watch_it/watch_it.dart';

import 'MyAppInfo.dart';
import 'data_repo.dart';
import 'list-item.dart';

class AppList extends StatefulWidget with WatchItStatefulWidgetMixin {
  const AppList({super.key});

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
  // final DataRepo dataRepo = getIt.watch<DataRepo>();
  final TextEditingController _searchController = TextEditingController();
  List<AppUsageInfo> _infos = [];

  @override
  void initState() {
    debugPrint('init state');
    super.initState();
    getApplications();
    loadTickSound();
    scrollController.addListener(_onScroll); // Add the listener
    getUsageStats();
  }

  @override
  void dispose() {
    scrollController.dispose(); // Dispose the controller
    _searchController.dispose();
    super.dispose();
  }

  void getUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(hours: 1));
      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(
        startDate,
        endDate,
      );
      setState(() => _infos = infoList);

      for (var info in infoList) {
        print(info.toString());
      }
    } on Exception catch (exception) {
      print(exception);
    }
  }

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

    if (!kIsWeb && !kDebugMode) {
      await Future.delayed(const Duration(seconds: 2));
    }
    setState(() {
      applications = apps ?? [];
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _previousScrollOffset = scrollController.offset;
      });
    });
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
    final dataRepo = watch(di<DataRepo>());
    var nonFavApps = applications
        .where(
          (app) => !(dataRepo.favorites.any(
            (x) => x.app.packageName == app.packageName,
          )),
        )
        .toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search...',
              border: InputBorder.none,
            ),
            keyboardType: TextInputType.text,
            onChanged: (value) {
              // Handle search logic here
            },
            cursorColor: Colors.black,
          ),
          surfaceTintColor: Colors.white30,
          // backgroundColor: Colors.amber,
          foregroundColor: Colors.red,

          // FilledButton(
          //   onPressed: () {
          //     debugPrint("Fav len: ${dataRepo.favorites.length}");
          //     dataRepo.loadFavorites();
          //   },
          //   child: Icon(Icons.settings),
          // ),
        ),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView.builder(
                controller: scrollController, // Attach the controller
                padding: const EdgeInsets.all(16),
                itemCount: dataRepo.favorites.length + nonFavApps.length,
                itemBuilder: (context, index) {
                  final app = index < dataRepo.favorites.length
                      ? dataRepo.favorites[index]
                      : MyAppInfo(
                          app: nonFavApps[index - dataRepo.favorites.length],
                        );
                  return ListItemForApp(app, (app) {
                    dataRepo.toggleFavorite(app);
                    setState(() {});
                  });
                },
              ),
            ),
    );
  }
}
