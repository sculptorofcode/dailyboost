import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notificationsPlugin.initialize(initSettings);
    tz.initializeTimeZones();
  }

  Future<void> requestNotificationPermission() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        // Permission granted
      } else if (status.isDenied) {
        // Permission denied
      } else if (status.isPermanentlyDenied) {
        // Permission permanently denied, open app settings
        await openAppSettings();
      }
    }
  }

  Future<void> requestExactAlarmPermissionIfNeeded() async {
    if (Platform.isAndroid) {
      // Only needed for Android 12+
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.getActiveNotifications();
    }
  }

  Future<void> scheduleDailyQuoteNotification({
    required int hour,
    required int minute,
    required String quote,
  }) async {
    await requestExactAlarmPermissionIfNeeded();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'daily_quote_channel',
          'Daily Quote Notifications',
          channelDescription: 'Daily motivational quote notification',
          importance: Importance.max,
          priority: Priority.high,
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      attachments: [],
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      badgeNumber: 1,
      subtitle: 'Your daily quote',
      threadIdentifier: 'daily_quote_thread',
      interruptionLevel: InterruptionLevel.timeSensitive,
      categoryIdentifier: 'daily_quote_category',
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = tz.TZDateTime.now(tz.local);
    final scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    final nextScheduledTime =
        scheduledTime.isBefore(now)
            ? scheduledTime.add(const Duration(days: 1))
            : scheduledTime;

    await _notificationsPlugin.zonedSchedule(
      0,
      'Daily Quote',
      quote,
      nextScheduledTime,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
