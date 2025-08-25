import 'package:DETOXD/services/sound_service.dart';
import 'package:get_it/get_it.dart';

import '../data/settings.dart';
import '../main.dart';
import '../theme_notifier.dart';
import 'app_list_service.dart';
import 'app_report_service.dart';

final locator = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton(Settings());
  // will be done later
  // getIt.registerSingleton(DataRepo());
  getIt.registerSingleton(SoundService());
  getIt.registerSingleton(ThemeNotifier());
  getIt.registerSingleton(AppListService());
  // getIt.registerLazySingleton(() => ApiService());
  // getIt.registerFactory(() => DataRepository(apiService: getIt<ApiService>()));
  locator.registerLazySingleton<AppReportService>(() => AppReportService());
}
