import 'package:DETOXD/pages/all_apps_launcher.dart';
import 'package:DETOXD/service/app_list_service.dart';
import 'package:DETOXD/swipable.dart';
import 'package:DETOXD/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_it/watch_it.dart';

import 'data/data_repo.dart';
// Import other platform implementations if you are targeting other platforms

import 'data/settings.dart';
import 'pages/applist/app_list.dart';
import 'pages/settings/settings_page.dart';
import 'service/sound_service.dart';

final getIt = GetIt.instance;

// GoRouter configuration
final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SwipeableScaffold()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(path: '/config', builder: (context, state) => const AppList()),
    GoRoute(
      path: '/widgets',
      builder: (context, state) => const AllAppsLauncher(),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  var settings = getIt<Settings>();
  await settings.init();
  runApp(const MyApp());
}

void setupDependencies() {
  getIt.registerSingleton(Settings());
  // will be done later
  // getIt.registerSingleton(DataRepo());
  getIt.registerSingleton(SoundService());
  getIt.registerSingleton(ThemeNotifier());
  getIt.registerSingleton(AppListService());
  // getIt.registerLazySingleton(() => ApiService());
  // getIt.registerFactory(() => DataRepository(apiService: getIt<ApiService>()));
}

class MyApp extends StatefulWidget with WatchItStatefulWidgetMixin {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    debugPrint('MyApp initState');
    super.initState();
    final dataRepo = DataRepo();
    getIt.registerSingleton(dataRepo);
    // for UI to start working
    Future.delayed(const Duration(milliseconds: 1500), () {
      dataRepo.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = watch(di<Settings>());
    final dataRepo = watch(di<DataRepo>());

    debugPrint(
      'MyApp build, isReady:${settings.isReady}, isLoading: ${dataRepo.isLoading}',
    );

    final themeNotifier = watch(di<ThemeNotifier>());
    var lightTheme = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      textTheme: TextTheme(
        // bodyLarge: TextStyle(color: Colors.white),
        // bodyMedium: TextStyle(color: Colors.white),
        // Add other text styles as needed
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Color(0xFF3297FD),
        // .withOpacity(0.5), // Choose your desired color and opacity
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
    );
    var darkTheme = ThemeData(
      brightness: Brightness.dark,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Color(
          0xFF3297FD,
        ).withOpacity(0.5), // Adjust for dark mode
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueAccent,
        brightness: Brightness.dark,
      ),
    );

    if (!settings.isReady || dataRepo.isLoading) {
      return MaterialApp(
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
        theme: lightTheme,
        darkTheme: darkTheme,
      );
    } else {
      return MaterialApp.router(
        routerConfig: _router,
        title: 'DETOXD',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode:
            themeNotifier.themeMode, // Or ThemeMode.light / ThemeMode.dark
      );
    }
  }
}
