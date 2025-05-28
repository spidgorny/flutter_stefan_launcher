import 'package:DETOXD/swipable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watch_it/watch_it.dart';

import 'data/data_repo.dart';
// Import other platform implementations if you are targeting other platforms

import 'data/settings.dart';
import 'pages/applist/app_list.dart';
import 'service/sound_service.dart';

final getIt = GetIt.instance;

// GoRouter configuration
final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SwipeableScaffold()),
    GoRoute(path: '/config', builder: (context, state) => const AppList()),
    GoRoute(path: '/widgets', builder: (context, state) => const AppList()),
  ],
);

void setupDependencies() {
  getIt.registerSingleton(Settings());
  getIt.registerSingleton(DataRepo());
  getIt.registerSingleton(SoundService());
  getIt.registerSingleton(ThemeNotifier());
  // getIt.registerLazySingleton(() => ApiService());
  // getIt.registerFactory(() => DataRepository(apiService: getIt<ApiService>()));
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget with WatchItStatefulWidgetMixin {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// 1. Define a ThemeNotifier class to manage theme state
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default theme
  final settings = getIt<Settings>();

  ThemeMode get themeMode =>
      settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Method to toggle the theme
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify listeners (like MaterialApp) to rebuild
  }

  // Optionally, a method to set a specific ThemeMode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final settings = watch(di<Settings>());
    final themeNotifier = watch(di<ThemeNotifier>());
    return MaterialApp.router(
      routerConfig: _router,
      title: 'DETOXD',
      theme: ThemeData(
        brightness: Brightness.light,
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Color(0xFF3297FD),
          // .withOpacity(0.5), // Choose your desired color and opacity
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      darkTheme: ThemeData(
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
      ),
      themeMode: themeNotifier.themeMode, // Or ThemeMode.light / ThemeMode.dark
    );
  }
}
