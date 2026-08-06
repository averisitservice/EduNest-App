import 'package:edunest/app/core/services/common_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('🔔 [Background Message] ${message.messageId}');
  }
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _isLocalInitialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    // 1. Enable foreground notification presentation for iOS (Alert, Badge, Sound)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Setup Local Notifications for Android & iOS foreground banners
    await _setupLocalNotifications();

    // 3. Register FCM Listeners
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Triggered when app receives notification while active in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print(
          '🔔 [Foreground] ${message.notification?.title}: ${message.notification?.body}',
        );
      }
      _showLocalNotificationBanner(message);
    });

    // Triggered when user taps on notification banner to open app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('🔔 [Notification Clicked] Data: ${message.data}');
      }
    });

    // Triggered when FCM token refreshes
    _messaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) {
        print(
          '\n==================== REFRESHED FCM TOKEN ====================',
        );
        print(newToken);
        print(
          '=============================================================\n',
        );
      }
    });
  }

  /// Initialize Local Notification Plugin for Android & iOS
  static Future<void> _setupLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(initSettings);

      // Create Android Notification Channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);

      _isLocalInitialized = true;
    } catch (e) {
      _isLocalInitialized = false;
      if (kDebugMode) {
        print('⚠️ Local notifications setup error: $e');
      }
    }
  }

  /// Show banner when notification arrives in foreground (Android & iOS)
  static void _showLocalNotificationBanner(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && _isLocalInitialized) {
      try {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error showing local notification: $e');
        }
      }
    }
  }

  /// Request notification permissions for both Android & iOS
  static Future<void> requestNotificationPermission() async {
    final bool hasAsked = await CommonService.hasAskedNotificationPermission();

    if (!hasAsked) {
      await CommonService.setAskedNotificationPermission(true);

      // 1. Request FCM permission (iOS alert/badge/sound)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        print(
          'iOS/Android authorization status: ${settings.authorizationStatus}',
        );
      }

      // 2. Request iOS Local Notifications permission
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      // 3. Permission Handler request
      try {
        await Permission.notification.request();
      } catch (_) {}
    }

    await getFcmToken();
  }

  /// Fetch and print FCM Device Token (Supports iOS APNs)
  static Future<String?> getFcmToken() async {
    try {
      // On iOS devices, check APNs token if needed
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken = await _messaging.getAPNSToken();
        if (kDebugMode && apnsToken != null) {
          debugPrint('APNs Token: $apnsToken');
        }
      }

      final token = await _messaging.getToken();
      if (kDebugMode) {
        print('\n==================== FCM TOKEN ====================');
        print(token ?? 'No token generated');
        print('===================================================\n');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get FCM token: $e');
      }
      return null;
    }
  }
}
