import 'package:DETOXD/swipable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

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
  // getIt.registerLazySingleton(() => ApiService());
  // getIt.registerFactory(() => DataRepository(apiService: getIt<ApiService>()));
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'DETOXD',
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Color(0xFF3297FD),
          // .withOpacity(0.5), // Choose your desired color and opacity
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
    );
  }
}
