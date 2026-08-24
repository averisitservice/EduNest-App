import 'package:edunest/app/UI/notifications/notification_page.dart';
import 'package:edunest/app/core/services/common_service.dart';
import 'package:edunest/app/data/repository/fcm_repo.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('🔔 [Background Message] ${message.messageId}');
  }
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // 1. Enable foreground notification presentation for iOS (Alert, Badge, Sound)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Register FCM Listeners
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Triggered when app receives notification while active in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print(
          '🔔 [Foreground] ${message.notification?.title}: ${message.notification?.body}',
        );
      }
    });

    // Triggered when user taps on notification banner while app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('🔔 [Notification Clicked] Data: ${message.data}');
      }
      _handleNotificationTap(message);
    });

    // Triggered when the app is opened by tapping a notification from a terminated state
    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

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
      _syncTokenIfLoggedIn(newToken);
    });
  }

  /// Navigates to the relevant screen based on the notification payload.
  /// Backend sends `data: {"type": "NOTIFICATION", ...}` on every push (see FcmPushServiceImpl).
  static void _handleNotificationTap(RemoteMessage message) {
    if (message.data['type'] == 'NOTIFICATION') {
      Get.to(() => const NotificationPage());
    }
  }

  /// Uploads a refreshed token to the backend, only if a student session already exists.
  static Future<void> _syncTokenIfLoggedIn(String fcmToken) async {
    final String? sessionToken = await CommonService.getSessionToken();
    if (sessionToken == null) return;

    try {
      await FcmRepo().saveFcmToken(fcmToken);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to sync refreshed FCM token: $e');
      }
    }
  }

  /// Removes this device's FCM token from the backend. Call before logging out.
  static Future<void> unregisterFcmToken() async {
    try {
      final String? fcmToken = await _messaging.getToken();
      if (fcmToken != null) {
        await FcmRepo().deleteFcmToken(fcmToken);
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to remove FCM token: $e');
      }
    }
  }

  /// Uploads the current FCM token to the backend. Call after a successful login.
  static Future<void> syncFcmToken() async {
    final String? fcmToken = await getFcmToken();
    if (fcmToken == null) return;

    try {
      await FcmRepo().saveFcmToken(fcmToken);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to save FCM token: $e');
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

      // 2. Permission Handler request
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
