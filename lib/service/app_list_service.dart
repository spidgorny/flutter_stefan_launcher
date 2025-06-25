import 'package:appcheck/appcheck.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final List<String> _largePackageBlacklist = [
  // --- Google System Components & Services ---
  'com.android.egg', // Android Easter Egg
  'com.google.android.adservices.api', // Privacy Sandbox Ad Services API
  'com.google.android.gms', // Google Play Services (Critical, but not launchable)
  'com.google.android.gsf', // Google Services Framework
  'com.google.android.syncadapters.contacts', // Contacts Sync Adapter
  'com.google.android.syncadapters.calendar', // Calendar Sync Adapter
  'com.google.android.packageinstaller', // Package Installer
  'com.google.android.webview', // Android System WebView
  'com.google.android.inputmethod.latin', // Gboard (Keyboard, not directly launched)
  'com.google.android.marvin.talkback', // Android Accessibility Suite (TalkBack)
  'com.google.android.apps.wellbeing', // Digital Wellbeing (often integrated into settings)
  'com.google.android.apps.gcs', // Google Connectivity Services
  'com.google.android.as', // Device Personalization Services / Actions Services
  'com.google.android.apps.pixelmigrate', // Data Transfer Tool (Pixel)
  'com.google.android.apps.restore', // Android Switch / Restore
  'com.google.android.apps.wifisetup.app', // Device Utility (Wi-Fi setup)
  'com.google.android.apps.safetycore', // SafetyCore (Sensitive Content Warnings)
  'com.google.android.apps.scone', // Adaptive Connectivity Services
  'com.google.android.apps.automotive.templates.host', // Automotive App Host
  'com.google.android.apps.automotive.inputmethod', // Automotive Keyboard
  'com.google.android.apps.mediashell', // Chromecast built-in
  'com.google.android.ims', // Carrier Services
  'com.google.android.tvrecommendations', // Android TV Core Services
  'com.google.android.tv.remote.service', // Android TV Remote Service
  'com.google.android.networkstack',
  'com.google.location.nearby.apps.fastpair.validator', // Fast Pair Validator
  'com.google.intelligence.sense', // Pixel Ambient Services
  // --- Android AOSP System Components ---
  'android', // Core Android system
  'com.android.systemui', // System UI (Status bar, navigation bar)
  'com.android.settings', // Settings app (often has a launcher icon, but can be filtered if desired)
  'com.android.providers.media', // Media Storage
  'com.android.providers.downloads', // Download Manager
  'com.android.providers.calendar', // Calendar Storage
  'com.android.providers.contacts', // Contacts Storage
  'com.android.providers.telephony', // Telephony Storage
  'com.android.providers.blockednumber', // Blocked Numbers Storage
  'com.android.providers.userdictionary', // User Dictionary
  'com.android.providers.settings', // Settings Storage
  'com.android.providers.partnerbookmarks', // Partner Bookmarks
  'com.android.bluetooth', // Bluetooth
  'com.android.camera.experimental2016', // Experimental Camera (often hidden)
  'com.android.certinstaller', // Certificate Installer
  'com.android.defcontainer', // Default Container
  'com.android.dreams.basic', // Basic Daydream/Screensaver
  'com.android.dreams.phototable', // Photo Table Daydream/Screensaver
  'com.android.externalstorage', // External Storage
  'com.android.internal',
  'com.android.inputdevices', // Input Devices
  'com.android.keychain', // Keychain
  'com.android.location.fused', // Fused Location
  'com.android.managedprovisioning', // Android for Work / Device Provisioning
  'com.android.mms.service', // MMS Service
  'com.android.mtp', // MTP Host
  'com.android.net.eap', // EAP-SIM/AKA/TTLS
  'com.android.nfc', // NFC Service
  'com.android.printspooler', // Print Spooler
  'com.android.server.telecom', // Telecom Service
  'com.android.sharedstoragebackup', // Shared Storage Backup
  'com.android.shell', // ADB Shell (not user-facing)
  'com.android.soundrecorder', // Sound Recorder (sometimes hidden)
  'com.android.stk', // SIM Toolkit
  'com.android.vpndialogs', // VPN Dialogs
  'com.android.wallpaper.livepicker', // Live Wallpaper Picker
  'com.android.wallpapercropper', // Wallpaper Cropper
  'com.android.cts.ctsshim', // CTS Shim
  'com.android.cts.priv.ctsshim', // CTS Privileged Shim
  'com.android.hotwordenrollment.okgoogle', // OK Google Enrollment
  'com.android.hotwordenrollment.xgoogle', // OK Google Enrollment (alternate)
  'com.android.hotwordenrollment.tgoogle', // OK Google Enrollment (alternate)
  'com.android.emergency', // Emergency Information
  // --- Manufacturer/OEM Specific (Common Examples - Varies HEAVILY by device) ---
  // Samsung Examples (many of these are services or components)
  'com.samsung.android.app.aodservice', // Always On Display service
  'com.samsung.android.app.social', // What's New / Social
  'com.samsung.android.authfw', // Samsung Authentication Framework
  'com.samsung.android.beaconmanager', // Samsung Beacon Manager (user tracking)
  'com.samsung.android.da.daagent', // Dual Messenger Agent
  'com.samsung.android.game.gamehome', // Game Launcher (the service part)
  'com.samsung.android.game.gametools', // Game Tools
  'com.samsung.android.game.gos', // Game Optimizing Service
  'com.samsung.android.hmt.vrsvc', // Gear VR Service
  'com.samsung.android.hmt.vrshell', // Gear VR Shell
  'com.samsung.android.kidsinstaller', // Kids Mode Installer
  'com.samsung.android.oneconnect', // SmartThings (service component)
  'com.samsung.android.samsungpass', // Samsung Pass
  'com.samsung.android.samsungpassautofill', // Samsung Pass Autofill
  'com.samsung.android.service.aircommand', // Air Command (Note series)
  'com.samsung.android.service.livedrawing', // Live Message (Note series)
  'com.samsung.android.service.peoplestripe', // Edge Panel for Contacts
  'com.samsung.android.svoiceime', // Samsung Voice Input
  'com.samsung.android.visionar', // AR Doodle
  'com.samsung.android.knox.kpu', // Knox Platform for Enterprise
  'com.samsung.android.knox.kpu.beta', // Knox Platform for Enterprise Beta
  'com.samsung.android.app.watchmanagerstub', // Galaxy Watch stub
  'com.samsung.android.sdk.handwriting', // Handwriting SDK
  'com.samsung.android.sdk.professionalaudio.utility.jammonitor', // Professional Audio utility
  'com.samsung.desktopsystemui', // DeX System UI
  'com.samsung.ecomm.global', // Samsung Shop
  'com.sec.android.app.camera.sticker.facearavatar.preload', // Camera stickers preload
  'com.sec.android.app.dexonpc', // Samsung DeX on PC
  'com.sec.android.app.kidshome', // Kids Home launcher (the service part)
  'com.sec.android.app.sbrowseredge', // Edge Panel for Samsung Internet
  'com.sec.android.daemonapp', // Samsung Weather daemon
  'com.sec.android.desktopmode.uiservice', // Desktop Mode UI service
  'com.sec.android.easyMover.Agent', // Samsung Smart Switch Agent
  'com.sec.android.app.chromecustomizations', // Chrome customizations
  'com.sec.android.app.voicenote', // Voice Recorder (sometimes hidden)
  'com.sec.penup', // PENUP (if not desired)
  // Xiaomi/MIUI Examples (many of these are services or components)
  'com.miui.analytics', // MIUI Analytics
  'com.miui.bugreport', // MIUI Feedback/Bug Report
  'com.miui.cloudbackup', // Mi Cloud Backup
  'com.miui.cloudservice', // Mi Cloud Service
  'com.miui.cloudservice.sysbase', // Mi Cloud Service (system base)
  'com.miui.daemon', // MIUI Daemon
  'com.miui.hybrid', // MIUI Hybrid Apps (web apps)
  'com.miui.hybrid.accessory', // MIUI Hybrid Accessory
  'com.miui.micloudsync', // Mi Cloud Sync
  'com.miui.miservice', // Mi Service
  'com.miui.mishare.connectivity', // Mi Share Connectivity
  'com.miui.nextpay', // MIUI Payment feature
  'com.miui.personalassistant', // MIUI Personal Assistant
  'com.miui.phrase', // MIUI Phrase
  'com.miui.smsextra', // MIUI SMS Extra
  'com.miui.systemAdSolution', // MIUI Ad Solution
  'com.miui.touchassistant', // MIUI Touch Assistant
  'com.miui.translation.kingsoft', // MIUI Translation Service
  'com.miui.translation.xmcloud', // MIUI Translation Service
  'com.miui.translation.youdao', // MIUI Translation Service
  'com.miui.translationservice', // MIUI Translation Service
  'com.miui.voiceassist', // MIUI Voice Assist
  'com.miui.voicetrigger', // MIUI Voice Trigger
  'com.miui.vsimcore', // MIUI Vsim Core
  'com.miui.wmsvc', // MIUI WMSVC
  'com.xiaomi.joyose', // Xiaomi Joyose (collects usage data)
  'com.xiaomi.location.fused', // Xiaomi Fused Location
  'com.xiaomi.mi_connect_service', // Mi Connect Service
  'com.xiaomi.micloud.sdk', // Mi Cloud SDK
  'com.xiaomi.registration', // Auto Registration
  'com.xiaomi.aon', // Mi AON Service
  'com.xiaomi.glgm', // Xiaomi GLGM
  'com.xiaomi.midrop', // MiDrop (file sharing)
  // Facebook Bloatware (often pre-installed by OEMs)
  'com.facebook.appmanager',
  'com.facebook.services',
  'com.facebook.system',
  // 'com.facebook.katana', // Main Facebook app (if you want to hide it)
  // Other common bloatware/background services
  'com.qualcomm.qti.qms.service.telemetry', // Qualcomm Telemetry
  'com.qualcomm.qti.smq', // Qualcomm SMQ
  'dsi.ant.service.socket', // ANT+ Radio Service
  'dsi.ant.plugins.antplus', // ANT+ Plugins Service
  // 'com.android.chrome', // Google Chrome (if you prefer to hide it and use another browser)
  // 'com.google.android.youtube', // YouTube (if you prefer to hide it)
  // 'com.google.android.gm', // Gmail (if you prefer to hide it)
  // 'com.google.android.apps.photos', // Google Photos (if you prefer to hide it)
  // 'com.google.android.apps.maps', // Google Maps (if you prefer to hide it)
  // 'com.google.android.calendar', // Google Calendar (if you prefer to hide it)
  // 'com.google.ar.lens', // Google Lens (often integrated, not always a separate launcher icon)
  // 'com.google.android.apps.nbu.files', // Files by Google (if you prefer to hide it)
  // 'com.google.android.apps.googleassistant', // Google Assistant (if you use gestures/voice for it)
  // 'com.google.android.googlequicksearchbox', // Google Search app (if you use gestures/voice for it)
  // 'com.google.android.projection.gearhead', // Android Auto (if you don't use it or launch it via car)
  // OEMConfig Clients (for enterprise device management, usually headless)
  'com.zebra.oemconfig.common',
  'com.samsung.android.knox.kpu', // Already listed, but re-emphasizing
  'com.honeywell.oemconfig',
  'com.datalogic.settings.oemconfig',
  'jp.kyocera.enterprisedeviceconfig',
  'com.hmdglobal.app.oemconfig.n7_2',
  'com.seuic.seuicoemconfig',
  'com.unitech.oemconfig',
  'com.lenovo.oemconfig.dev',
  'com.lenovo.dpc.oemconfig',
  'com.cipherlab.oemconfig',
  'com.ecom.econfig.smart',
  'com.ascom.myco.oemconfig',
  'com.zebra.enrollment', // Zebra Enrollment Manager
  // Miscellaneous
  'com.android.vending', // Google Play Store (usually has a launcher, but some might want to hide it)
  'com.android.calculator2', // AOSP Calculator (if a different one is preferred)
  'com.android.deskclock', // AOSP Clock (if a different one is preferred)
  'com.android.email', // AOSP Email (older versions)
  'com.android.gallery3d', // AOSP Gallery (older versions)
  'com.android.music', // AOSP Music (older versions)
  'com.android.browser', // AOSP Browser (older versions)

  'com.android.traceur',
  'com.android.storagemanager.auto_generated_rro_product__',
  'com.google.android.cellbroadcastreceiver',
  'com.android.phone.auto_generated_rro_product__',
  'com.android.devicelockcontroller',
  'com.google.android.photopicker',
  'com.google.android.uwb.resources.goldfish.overlay',
  'com.google.android.ondevicepersonalization.services',
  'com.android.companiondevicemanager.auto_generated_characteristics_rro',
  'com.android.wallpaperbackup',
  'com.google.android.odad',
  'com.google.android.apps.wallpaper',
  'com.android.wallpaper',
  'com.google.android.telephony.satellite',
  'com.google.android.wifi',
  'com.google.android.uwb',
  'com.google.android.projection',
  'com.google.android.settings',
  'com.google.android.overlay',
  'com.android.bookmarkprovider',
  'com.android.storagemanager',
  'com.google.android.healthconnect.controller',
  'com.android.imsserviceentitlement',
  'com.google.mainline.adservices',
  'com.android.phone.auto_generated_rro_vendor__',
  'com.android.role.notes.enabled',
  'com.google.android.overlay',
  'com.android.devicediagnostics',
  'com.android.emulator',
  'com.android.carrierconfig',
  'com.google.mainline',
  'com.android.dynsystem',
  'com.android.pacprocessor',
  'com.google.android.ext',
  'com.google.android.bluetooth',
  'com.android.calllogbackup',
  'com.google.android.providers',
  'com.google.android.nfc',
  'com.google.android.permissioncontroller',
  'com.google.android.soundpicker',
  'com.google.android.tag',
  'com.google.android.tts',
  'com.google.android.nfc',
  'com.android.providers',
  'com.google.android.captiveportallogin',
  'com.android.carrierdefaultapp',
  'com.android.credentialmanager',
  'com.android.bips',
];

class AppListService with ChangeNotifier {
  var startTime = DateTime.now();
  bool isLoading = true;
  List<AppInfo> applications = [];

  debugPrintX(String message) {
    debugPrint('${DateTime.now().difference(startTime)} $message');
    startTime = DateTime.now();
  }

  AppListService() {
    getApplications();
  }

  Future<void> getApplications() async {
    debugPrintX('getApplications start');
    isLoading = true;
    // Run the app fetching and processing in a separate isolate
    foundation
        .compute(_fetchAndProcessApps, {
          'rootIsolateToken': RootIsolateToken.instance!,
          // 'apps': apps,
          'blackList': _largePackageBlacklist,
        })
        .then((processedApps) {
          debugPrintX('getApplications done: ${processedApps.length} apps');
          isLoading = false;
          applications = processedApps;
          notifyListeners();
        });
  }

  // This function will be executed in a separate isolate
  static Future<List<AppInfo>> _fetchAndProcessApps(
    Map<String, dynamic> args,
  ) async {
    RootIsolateToken rootIsolateToken = args['rootIsolateToken'];
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    final appCheck = AppCheck();
    var apps = await appCheck.getInstalledApps();
    // List<AppInfo>? apps = args['apps'];
    List<String> blacklist = args['blackList'];
    // debugPrintX is not available in isolate, use debugPrint directly if needed
    debugPrint('Isolate: getInstalledApps');
    debugPrint('Isolate: installed apps: ${apps?.length}');

    if (apps == null || apps.isEmpty) {
      return [];
    }

    // Find the badIconApp within the isolate if necessary, or pass its details
    AppInfo? badIconApp;
    try {
      badIconApp = apps.firstWhere(
        (AppInfo app) => app.packageName == 'com.android.htmlviewer',
      );
    } catch (e) {
      // Handle case where badIconApp is not found, if necessary
      debugPrint('Isolate: com.android.htmlviewer not found.');
    }

    apps = apps.where((AppInfo app) {
      bool isBlacklisted = blacklist.any(
        (String x) => app.packageName.startsWith(x),
      );
      if (isBlacklisted) return false;

      if (badIconApp != null &&
          app.icon != null &&
          badIconApp.icon != null &&
          foundation.listEquals(app.icon, badIconApp.icon)) {
        return false;
      }
      return true;
    }).toList();

    apps.sort(
      (a, b) => (a.appName ?? "").toLowerCase().compareTo(
        (b.appName ?? "").toLowerCase(),
      ),
    );
    return apps;
  }
}
