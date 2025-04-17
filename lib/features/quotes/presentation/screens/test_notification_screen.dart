import 'package:flutter/material.dart';
import '../../../../core/utils/notification_service.dart';
import 'package:intl/intl.dart';

class TestNotificationScreen extends StatelessWidget {
  const TestNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Notification Service')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final now = DateTime.now();
            final testTime = now.add(const Duration(minutes: 1));
            final notificationService = NotificationService();
            await notificationService.init();
            await notificationService.scheduleDailyQuoteNotification(
              id: 999, // test notification id
              hour: testTime.hour,
              minute: testTime.minute,
              quote:
                  'This is a test notification at ${DateFormat.Hm().format(testTime)}',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Notification scheduled for ${DateFormat.Hm().format(testTime)}',
                ),
              ),
            );
          },
          child: const Text('Schedule Test Notification (1 min from now)'),
        ),
      ),
    );
  }
}
