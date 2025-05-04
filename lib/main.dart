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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AppList(title: 'Flutter Demo Home Page'),
    );
  }
}
