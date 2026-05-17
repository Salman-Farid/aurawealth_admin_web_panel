// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import 'storage_service.dart';

/// Registers the admin panel's FCM token so the backend can notify admins when
/// users write new Firestore chat messages.
class AdminFcmService {
  AdminFcmService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final StorageService _storage = StorageService();

  static Future<void> initialize() async {
    try {
      print('[AdminFCM] initialize() started');
      print(
        '[AdminFCM] Firebase apps initialized count: ${Firebase.apps.length}',
      );
      print(
        '[AdminFCM] Firebase default app available before FCM init: '
        '${Firebase.apps.isNotEmpty}',
      );
      final currentUri = Uri.base;
      final isSecureFcmOrigin =
          currentUri.scheme == 'https' ||
          currentUri.host == 'localhost' ||
          currentUri.host == '127.0.0.1';
      print('[AdminFCM] Current page URL for Web FCM: $currentUri');
      print(
        '[AdminFCM] Web FCM secure origin check: '
        'scheme=${currentUri.scheme}, host=${currentUri.host}, '
        'allowed=$isSecureFcmOrigin '
        '(must be HTTPS or localhost/127.0.0.1)',
      );
      final authToken = _storage.getAuthToken();
      print(
        '[AdminFCM] Auth token available before FCM registration: '
        '${authToken != null && authToken.isNotEmpty}',
      );

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('[AdminFCM] Permission: ${settings.authorizationStatus}');

      String? token;
      try {
        token = await FirebaseMessaging.instance.getToken(
          vapidKey:
              'BDUiGW559E7LUJ5PZMIcvJxBAmwpPEpCRfu3Emj8Xg6B5SfJNL5Yt667Ms3qubMzA8lrMbcnQ5yhHaYb60Imnfw',
        );
        print('[AdminFCM] Raw FCM getToken() value: $token');
      } catch (e, stackTrace) {
        print('[AdminFCM] getToken() error: $e');
        print('[AdminFCM] getToken() stack trace: $stackTrace');
        rethrow;
      }
      print(
        '[AdminFCM] Device token adding decision: '
        '${token != null && token.isNotEmpty ? 'will add/send token to backend' : 'will NOT add/send token because token is null/empty'}',
      );
      if (token == null || token.isEmpty) {
        print('[AdminFCM] No FCM token available');
        return;
      }

      print('[AdminFCM] About to send/add device token to backend');
      await _registerToken(token);
      FirebaseMessaging.instance.onTokenRefresh.listen(
        (refreshedToken) {
          print('[AdminFCM] Token refreshed: $refreshedToken');
          _registerToken(refreshedToken);
        },
        onError: (Object error, StackTrace stackTrace) {
          print('[AdminFCM] Token refresh listener error: $error');
          print('[AdminFCM] Token refresh listener stack trace: $stackTrace');
        },
      );

      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        final title =
            notification?.title ??
            message.data['title']?.toString() ??
            'AuraWealth';
        final body =
            notification?.body ?? message.data['body']?.toString() ?? '';
        if (body.isNotEmpty) {
          Get.snackbar(title, body, duration: const Duration(seconds: 4));
        }
      });
      print('[AdminFCM] initialize() completed');
    } catch (e, stackTrace) {
      print('[AdminFCM] Initialization skipped/failed: $e');
      print('[AdminFCM] Initialization stack trace: $stackTrace');
    }
  }

  static Future<void> _registerToken(String token) async {
    final url = Uri.parse('${AppConstants.baseUrl}/admin/fcm-token');
    final authToken = _storage.getAuthToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (authToken != null && authToken.isNotEmpty)
        'Authorization': 'Bearer $authToken',
    };
    final body = <String, dynamic>{
      'token': token,
      'device_name': 'admin_panel',
    };
    final encodedBody = json.encode(body);

    try {
      print('[AdminFCM] POST /admin/fcm-token request URL: $url');
      print(
        '[AdminFCM] POST /admin/fcm-token request headers: '
        '${_redactSensitiveHeaders(headers)}',
      );
      print('[AdminFCM] POST /admin/fcm-token request body: $encodedBody');

      print('[AdminFCM] HTTP POST is being made now');
      final response = await http
          .post(url, headers: headers, body: encodedBody)
          .timeout(Duration(seconds: AppConstants.apiTimeout));
      print('[AdminFCM] HTTP POST completed');

      print(
        '[AdminFCM] POST /admin/fcm-token response status: '
        '${response.statusCode}',
      );
      print(
        '[AdminFCM] POST /admin/fcm-token response headers: '
        '${response.headers}',
      );
      print(
        '[AdminFCM] POST /admin/fcm-token response body: '
        '${response.body}',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'POST /admin/fcm-token failed with HTTP ${response.statusCode}: '
          '${response.body}',
        );
      }

      print('[AdminFCM] Admin FCM token registered: $token');
    } catch (e, stackTrace) {
      print('[AdminFCM] Token registration failed: $e');
      print('[AdminFCM] Token registration stack trace: $stackTrace');
    }
  }

  static Map<String, String> _redactSensitiveHeaders(
    Map<String, String> headers,
  ) {
    return headers.map((key, value) {
      if (key.toLowerCase() == 'authorization') {
        return MapEntry(key, _redactBearerToken(value));
      }
      return MapEntry(key, value);
    });
  }

  static String _redactBearerToken(String value) {
    const prefix = 'Bearer ';
    if (!value.startsWith(prefix)) return '[redacted]';

    final token = value.substring(prefix.length);
    if (token.length <= 12) return 'Bearer [redacted]';

    return 'Bearer ${token.substring(0, 6)}...${token.substring(token.length - 4)}';
  }
}
