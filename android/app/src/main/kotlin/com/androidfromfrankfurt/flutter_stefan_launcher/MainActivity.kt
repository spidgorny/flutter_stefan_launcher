package com.androidfromfrankfurt.flutter_stefan_launcher

import android.annotation.TargetApi
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
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
                val dataFromKotlin = openAppInfo(packageName)
                result.success(dataFromKotlin)
            } else if (call.method == "openLauncherDialog") {
                val dataFromKotlin = openLauncherDialog()
                result.success(dataFromKotlin)
            } else if (call.method == "getInstalledAppsWithoutIcons") {
                result.success(getInstalledAppsWithoutIcons())
            }
            else {
                result.notImplemented()
            }
        }
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    private fun openLauncherDialog() {
        try {
            val intent = Intent(Settings.ACTION_HOME_SETTINGS)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            this.startActivity(intent);
        } catch (e: Exception) {
            Toast.makeText(this, "Could not open launcher settings.", Toast.LENGTH_SHORT).show()
        }
    }

    @androidx.annotation.RequiresApi(Build.VERSION_CODES.GINGERBREAD)
    private fun openAppInfo(packageName: String?): String {
        val message = "Hello from Kotlin! Received: text=$packageName"
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        val uri = Uri.fromParts("package", packageName, null)
        intent.data = uri
        this.startActivity(intent)
        return message
    }

    @Suppress("DEPRECATION")
    private fun getVersionCode(packageInfo: PackageInfo): Long {
        return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) packageInfo.versionCode.toLong()
        else packageInfo.longVersionCode
    }

    private fun getInstalledAppsWithoutIcons(): List<Map<String, Any?>> {
        val packageManager: PackageManager = context.packageManager
        val packages = packageManager.getInstalledPackages(0)
        val installedApps: MutableList<Map<String, Any?>> = ArrayList(packages.size)
        for (pkg in packages) {
            val app: MutableMap<String, Any?> = HashMap()
            val appInfo = pkg.applicationInfo

            if (appInfo != null) {
                app["app_name"] = appInfo.loadLabel(packageManager).toString()
                app["system_app"] = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
            } else {
                app["app_name"] = "N/A"
                app["system_app"] = false
            }

            app["package_name"] = pkg.packageName
            app["version_name"] = pkg.versionName?.toString() // versionName can be null
            app["version_code"] = getVersionCode(pkg)
            
            installedApps.add(app)
        }
        return installedApps
    }


    // Example of calling a Flutter function from Kotlin (bi-directional communication)
    fun sendEventToFlutter(eventName: String, data: Any?) {
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
            .invokeMethod("onKotlinEvent", mapOf("eventName" to eventName, "data" to data))
    }

}
