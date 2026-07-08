import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    try {
      // Request notification permission for iOS
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print('User granted permission: ${settings.authorizationStatus}');
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Got a message while in the foreground!');
          print('Message data: ${message.data}');
        }

        if (message.notification != null) {
          _showLocalNotification(
            title: message.notification!.title ?? 'Period Reminder',
            body: message.notification!.body ?? 'Your reminder',
          );
        }
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Get FCM token
      final String? token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notifications: $e');
      }
      // Continue without notifications
    }
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('app_icon');

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {
          if (kDebugMode) {
            print('iOS notification received: $title - $body');
          }
        },
      );

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (kDebugMode) {
            print('Notification tapped: ${response.payload}');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing local notifications: $e');
      }
      // Continue without local notifications
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'period_reminder_channel',
      'Period Reminder',
      channelDescription: 'Notification channel for period reminders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'period_reminder',
    );
  }

  /// Schedule a notification for the next period
  /// [periodStartDate] - the start date of the current period
  /// [periodLength] - length of the period in days (default 5)
  /// [daysBeforeNotification] - how many days before the next period to notify (default 1)
  Future<void> scheduleNextPeriodReminder({
    required DateTime periodStartDate,
    required int periodLength,
    int daysBeforeNotification = 1,
  }) async {
    try {
      // Calculate next period date
      const int cycleLength = 28; // Standard cycle length
      final DateTime nextPeriodDate =
          periodStartDate.add(const Duration(days: cycleLength));

      // Calculate notification date (days before the next period)
      final DateTime notificationDate =
          nextPeriodDate.subtract(Duration(days: daysBeforeNotification));

      final now = DateTime.now();
      if (notificationDate.isBefore(now)) {
        if (kDebugMode) {
          print(
              'Notification date is in the past, scheduling for next cycle');
        }
        return;
      }

      // Calculate days until next period
      final int daysUntilNextPeriod =
          nextPeriodDate.difference(now).inDays;

      final String nextPeriodDateFormatted =
          '${nextPeriodDate.year}-${nextPeriodDate.month.toString().padLeft(2, '0')}-${nextPeriodDate.day.toString().padLeft(2, '0')}';

      final String title = 'Period Reminder';
      final String body =
          'Next period in $daysUntilNextPeriod days (around $nextPeriodDateFormatted)';

      if (kDebugMode) {
        print('Scheduling notification for: $notificationDate');
        print('Days until next period: $daysUntilNextPeriod');
        print('Notification message: $body');
      }

      // For web and testing, show immediate notification
      if (kIsWeb) {
        await _showLocalNotification(title: title, body: body);
      } else {
        // For mobile platforms, use scheduled notifications
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'period_reminder_channel',
          'Period Reminder',
          channelDescription: 'Notification channel for period reminders',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

        const DarwinNotificationDetails iOSPlatformChannelSpecifics =
            DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics,
        );

        await _localNotifications.zonedSchedule(
          1,
          title,
          body,
          _convertToTZDateTime(notificationDate),
          platformChannelSpecifics,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }

      if (kDebugMode) {
        print('Period reminder scheduled successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling notification: $e');
      }
    }
  }

  /// Calculate days until next period
  int calculateDaysUntilNextPeriod({
    required DateTime periodStartDate,
  }) {
    const int cycleLength = 28;
    final DateTime nextPeriodDate =
        periodStartDate.add(const Duration(days: cycleLength));
    final int daysUntil = nextPeriodDate.difference(DateTime.now()).inDays;
    return daysUntil > 0 ? daysUntil : 0;
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // Helper method to convert DateTime to TZDateTime (required for iOS)
  dynamic _convertToTZDateTime(DateTime dateTime) {
    // For simplicity, using DateTime directly
    // In production, you'd use the timezone package
    return dateTime;
  }
}

// Background message handler for Firebase Cloud Messaging
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling a background message: ${message.messageId}');
  }
}
