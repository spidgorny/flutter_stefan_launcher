import 'package:flutter/material.dart';
import 'package:flutter_stefan_launcher/data_repo.dart';
import 'package:get_it/get_it.dart';

// Import other platform implementations if you are targeting other platforms

import 'app_list.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton(DataRepo());
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
    return MaterialApp(
      title: 'Stefan Launcher',
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Color(
            0xFF3297FD,
          ).withOpacity(0.5), // Choose your desired color and opacity
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const AppList(),
    );
  }
}
