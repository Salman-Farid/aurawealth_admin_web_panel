import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import 'api_service.dart';

/// Registers the admin panel's FCM token so the backend can notify admins when
/// users write new Firestore chat messages.
class AdminFcmService {
  AdminFcmService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final ApiService _api = ApiService();

  static Future<void> initialize() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('[AdminFCM] Permission: ${settings.authorizationStatus}');

      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        print('[AdminFCM] No FCM token available');
        return;
      }

      await _registerToken(token);
      FirebaseMessaging.instance.onTokenRefresh.listen(_registerToken);

      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        final title = notification?.title ?? message.data['title']?.toString() ?? 'AuraWealth';
        final body = notification?.body ?? message.data['body']?.toString() ?? '';
        if (body.isNotEmpty) {
          Get.snackbar(title, body, duration: const Duration(seconds: 4));
        }
      });
    } catch (e) {
      print('[AdminFCM] Initialization skipped/failed: $e');
    }
  }

  static Future<void> _registerToken(String token) async {
    try {
      await _api.post('${AppConstants.baseUrl}/admin/fcm-token', {
        'token': token,
        'device_name': 'admin_panel',
      });
      print('[AdminFCM] Admin FCM token registered');
    } catch (e) {
      print('[AdminFCM] Token registration failed: $e');
    }
  }
}
