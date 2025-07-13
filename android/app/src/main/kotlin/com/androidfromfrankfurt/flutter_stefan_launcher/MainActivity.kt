package com.androidfromfrankfurt.flutter_stefan_launcher

import android.annotation.TargetApi
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode.transparent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.androidfromfrankfurt.flutter_stefan_launcher/my_platform_service"

    override fun onCreate(savedInstanceState: Bundle?) {
        intent.putExtra("background_mode", transparent.toString())
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // This block is executed when a method is invoked from Flutter
                call, result ->
            if (call.method == "openAppInfo") {
                val packageName = call.argument<String>("packageName")
//                val param2 = call.argument<Int>("param2")

                // Call your actual Kotlin function here
                val dataFromKotlin = openAppInfo(packageName)

                // Send the result back to Flutter
                result.success(dataFromKotlin)
            } else if (call.method == "openLauncherDialog") {
                val dataFromKotlin = openLauncherDialog();

                // Send the result back to Flutter
                result.success(dataFromKotlin)
            } else {
                // If the method is not recognized, indicate it's not implemented
                result.notImplemented()
            }
        }
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private fun openLauncherDialog() {
        try {
            val intent = Intent(Settings.ACTION_HOME_SETTINGS)
            // Add this flag if you are starting the activity from a context
            // that is not an Activity (e.g., a Service or Application context)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            this.startActivity(intent);
        } catch (e: Exception) {
            // Handle the case where the Intent is not available on some devices.
            // This is unlikely for this specific Intent but is good practice.
            Toast.makeText(this, "Could not open launcher settings.", Toast.LENGTH_SHORT).show()
        }
    }

    // Your actual Kotlin function
    @androidx.annotation.RequiresApi(Build.VERSION_CODES.GINGERBREAD)
    private fun openAppInfo(packageName: String?): String {
        // Perform some native Android operations or calculations
        val message = "Hello from Kotlin! Received: text=$packageName"
//        Toast.makeText(this, message, Toast.LENGTH_SHORT).show() // Example: show a Toast
        // `context` here refers to the `Context` of the `MainActivity`.
        // `FlutterActivity` (which `MainActivity` extends) is a subclass of `ComponentActivity`,
        // which in turn is a subclass of `ContextThemeWrapper`, which itself is a `Context`.
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        val uri = Uri.fromParts("package", packageName, null)
        intent.data = uri
        this.startActivity(intent)
        return message
    }

    // Example of calling a Flutter function from Kotlin (bi-directional communication)
    fun sendEventToFlutter(eventName: String, data: Any?) {
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
            .invokeMethod("onKotlinEvent", mapOf("eventName" to eventName, "data" to data))
    }

}
