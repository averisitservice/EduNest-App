import 'dart:io';

import 'package:edunest/app/UI/features/leave/leave_list_page.dart';
import 'package:edunest/app/UI/home/home_page.dart';
import 'package:edunest/app/core/services/common_service.dart';
import 'package:edunest/app/data/repository/notification_repo.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No-op: the system tray already shows notification-type FCM messages
  // while the app is backgrounded/terminated. This handler exists so data-only
  // messages are still delivered to the app process.
}

class PushNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _androidChannelId = 'edunest_default_channel';

  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initLocalNotifications();
    await _requestPermission();

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    _messaging.onTokenRefresh.listen((token) => _registerToken(token));

    await registerCurrentToken();
  }

  static Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Local notification tapped while app is in foreground/background.
      },
    );

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _androidChannelId,
        'General notifications',
        description: 'School announcements, leave, homework and attendance updates.',
        importance: Importance.high,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  static Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  static void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          'General notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'];
    switch (type) {
      case 'LEAVE':
        Get.to(() => const LeaveListPage());
        break;
      default:
        Get.to(() => const HomePage());
    }
  }

  /// Fetches the current FCM token and registers it with the backend.
  /// Safe to call whenever there's an active session (app start, after login).
  static Future<void> registerCurrentToken() async {
    final sessionToken = await CommonService.getSessionToken();
    if (sessionToken == null || sessionToken.isEmpty) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    await _registerToken(token);
  }

  static Future<void> _registerToken(String token) async {
    final sessionToken = await CommonService.getSessionToken();
    if (sessionToken == null || sessionToken.isEmpty) return;

    final platform = Platform.isIOS ? 'IOS' : 'ANDROID';
    try {
      await NotificationRepo().registerDeviceToken(token, platform);
    } catch (e) {
      debugPrint('Failed to register device token: $e');
    }
  }

  /// Call on logout so this device stops receiving pushes for the signed-out student.
  static Future<void> unregisterCurrentToken() async {
    final token = await _messaging.getToken();
    if (token == null) return;
    try {
      await NotificationRepo().unregisterDeviceToken(token);
    } catch (e) {
      debugPrint('Failed to unregister device token: $e');
    }
  }
}
