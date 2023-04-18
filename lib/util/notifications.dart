import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:marshall_event_notifier/ui_elements/settings.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class EventNotification {
  int id;
  String title;
  DateTime eventDate;

  EventNotification(this.id, this.title, this.eventDate);
}

Map<NotifyBefore, Duration> notifyDurationMap = {
  NotifyBefore.minutes15Before: const Duration(minutes: 15),
  NotifyBefore.minutes30Before: const Duration(minutes: 30),
  NotifyBefore.minutes45Before: const Duration(minutes: 45),
  NotifyBefore.hour1Before: const Duration(hours: 1),
  NotifyBefore.hour2Before: const Duration(hours: 2),
  NotifyBefore.hour4Before: const Duration(hours: 4),
  NotifyBefore.hour8Before: const Duration(hours: 8),
  NotifyBefore.hour12Before: const Duration(hours: 12),
  NotifyBefore.day1Before: const Duration(days: 1),
  NotifyBefore.day2Before: const Duration(days: 2),
  NotifyBefore.day3Before: const Duration(days: 3),
  NotifyBefore.week1Before: const Duration(days: 7)
};

class NotificationsProvider {
  FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool isInit = false;

  Future<void> init() async {
    isInit = await notificationsPlugin.initialize(const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'))) ??
        false;
    _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    // Request notification permissions
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
  }

  void cancelNotification(int id) {
    for (var key in NotifyBefore.values) {
      debugPrint('removing -> ${key.name} from $id');
      notificationsPlugin.cancel(int.parse('$id${key.index}'));
    }
  }

  Future<void> notifyBackground(EventNotification notif) async {
    final timeZone = await FlutterNativeTimezone.getLocalTimezone();
    for (var key in NotifyBefore.values) {
      var value = Settings.getValue<bool>(key.name, defaultValue: false);
      debugPrint('$key -> ${key.name} -> $value');
      if (value == null || !value) {
        continue;
      }
      debugPrint('${notif.eventDate}');
      var notifyDate = notif.eventDate.subtract(notifyDurationMap[key]!);
      if (notifyDate.millisecondsSinceEpoch <
          tz.TZDateTime.now(tz.getLocation(timeZone)).millisecondsSinceEpoch) {
        debugPrint('date is before now...');
        continue;
      }
      debugPrint('cancelling ${notif.id}${key.index}');
      notificationsPlugin.cancel(int.parse('${notif.id}${key.index}'));
      debugPrint('adding ${notif.id}${key.index}');
      notificationsPlugin.zonedSchedule(
        int.parse('${notif.id}${key.index}'),
        notif.title,
        'Starts in ${key.get()}',
        tz.TZDateTime.from(notifyDate, tz.getLocation(timeZone)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
          'marshall_event_notifier',
          'Marshall Event Notifier',
          onlyAlertOnce: true,
        )),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
      );
    }
  }
}
