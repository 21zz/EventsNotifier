import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'ui_elements/settings.dart';
import 'ui_elements/navigation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.init(cacheProvider: SharePreferenceCache());
  tz.initializeTimeZones();
  final String locationName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(locationName));
  debugPrint('calling notification init');
  const androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "Marshall Event Notifier",
    notificationText: "Running in background",
    notificationImportance: AndroidNotificationImportance.Default,
    notificationIcon: AndroidResource(
        name: 'background_icon',
        defType: 'drawable'), // Default is ic_launcher from folder mipmap
  );
  bool success =
      await FlutterBackground.initialize(androidConfig: androidConfig);
  if (success) {
    FlutterBackground.enableBackgroundExecution();
    debugPrint('running in background');
  }
  runApp(const MUApp());
}

class MUApp extends StatelessWidget {
  const MUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueChangeObserver<bool>(
        cacheKey: DarkMode.darkMode.name,
        defaultValue: false,
        builder: (_, isDarkMode, __) => MaterialApp(
              debugShowCheckedModeBanner: true,
              title: "Marshall Events Notifier",
              theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
              home: const Navigation(),
            ));
  }
}
