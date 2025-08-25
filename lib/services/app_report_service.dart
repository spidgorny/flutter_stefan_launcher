import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';

class AppReportService {
  final Dio _dio;
  String? _userId;
  final String _apiUrl;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  AppReportService({
    Dio? dio,
    String apiUrl = 'https://nextjs-scan-menu.vercel.app/api/detoxd',
    String? userId,
  }) : _dio = dio ?? Dio(),
       _apiUrl = apiUrl,
       _userId = userId {
    _initDeviceId();
  }

  Future<void> _initDeviceId() async {
    if (_userId != null) return;

    try {
      final androidInfo = await _deviceInfo.androidInfo;
      _userId = androidInfo.id;
    } catch (e) {
      _userId = 'unknown_device';
    }
  }

  /// Reports an app to the server
  ///
  /// [packageName] - The package name of the app to report
  /// [appName] - The display name of the app
  Future<void> reportApp({
    required String packageName,
    required String appName,
  }) async {
    try {
      await _initDeviceId();
      final response = await _dio.post(
        _apiUrl,
        data: {
          'packageName': packageName,
          'appName': appName,
          'reportedBy': _userId ?? 'unknown_device',
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to report app: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error reporting app: $e');
    }
  }
}
