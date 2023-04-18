import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'ui_elements/settings.dart';
import 'ui_elements/navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.init(cacheProvider: SharePreferenceCache());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
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
              debugShowCheckedModeBanner: false,
              title: "Marshall Events Notifier",
              theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
              home: const Navigation(),
            ));
  }
}
