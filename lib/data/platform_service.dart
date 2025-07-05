import 'package:flutter/services.dart';

class MyPlatformService {
  // Define a unique channel name. It's good practice to use a reverse domain name.
  static const MethodChannel _channel = MethodChannel(
    'com.androidfromfrankfurt.flutter_stefan_launcher/my_platform_service',
  );

  Future<String> openAppInfo(String packageName) async {
    try {
      // Invoke a method on the platform channel.
      // The string 'myKotlinMethod' is the name of the function you'll call in Kotlin.
      // You can also pass arguments in a Map<String, dynamic> if needed.
      final String result = await _channel.invokeMethod('openAppInfo', {
        'packageName': packageName,
      });
      return result;
    } on PlatformException catch (e) {
      // Handle any errors that occur during the method call.
      print("Failed to invoke Kotlin method: '${e.message}'.");
      return "Error: ${e.message}";
    }
  }

  // Example of a Kotlin function returning data to Flutter asynchronously
  Future<void> listenToKotlinEvents() async {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onKotlinEvent':
          // Handle the event from Kotlin
          print('Received event from Kotlin: ${call.arguments}');
          break;
        default:
          throw PlatformException(
            code: 'UNIMPLEMENTED',
            message: 'Unknown method ${call.method}',
          );
      }
    });
  }
}
