import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../services/storage_service.dart';
import '../../shared/models/payment_request.dart';
import '../../shared/models/payment_transaction.dart';
import '../models/stripe_config.dart';
import '../models/stripe_payment_intent.dart';

class StripePaymentService {
  final StripeConfig config;
  final String baseUrl;
  final StorageService _storage;

  StripePaymentService({
    required this.config,
    this.baseUrl = AppConstants.baseUrl,
    StorageService? storage,
  }) : _storage = storage ?? StorageService();

  Future<StripePaymentIntent> createPaymentIntent(
    PaymentRequest request,
  ) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl${config.createPaymentIntentPath}'),
          headers: _headers(),
          body: jsonEncode(request.toJson()),
        )
        .timeout(Duration(seconds: AppConstants.apiTimeout));

    return StripePaymentIntent.fromJson(_parseMap(response));
  }

  Future<PaymentTransaction> confirmPayment({
    required String paymentIntentId,
    String? note,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl${config.confirmPaymentPath}'),
          headers: _headers(),
          body: jsonEncode(<String, dynamic>{
            'payment_intent_id': paymentIntentId,
            if (note != null && note.isNotEmpty) 'note': note,
          }),
        )
        .timeout(Duration(seconds: AppConstants.apiTimeout));

    return PaymentTransaction.fromJson(_parseMap(response));
  }

  Future<List<PaymentTransaction>> fetchTransactions({
    int limit = 50,
    int skip = 0,
  }) async {
    final uri = Uri.parse('$baseUrl${config.transactionsPath}').replace(
      queryParameters: <String, String>{'limit': '$limit', 'skip': '$skip'},
    );
    final response = await http
        .get(uri, headers: _headers())
        .timeout(Duration(seconds: AppConstants.apiTimeout));
    final decoded = _parseDynamic(response);
    final list = decoded is List
        ? decoded
        : decoded is Map<String, dynamic>
        ? (decoded['transactions'] ?? decoded['data'] ?? <dynamic>[])
              as List<dynamic>
        : <dynamic>[];

    return list
        .whereType<Map>()
        .map(
          (item) =>
              PaymentTransaction.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Map<String, String> _headers() {
    final token = _storage.getAuthToken();
    return <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _parseMap(http.Response response) {
    final decoded = _parseDynamic(response);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    throw Exception('Unexpected Stripe response format');
  }

  dynamic _parseDynamic(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return <String, dynamic>{'success': true};
      return jsonDecode(response.body);
    }

    String message = 'Stripe request failed';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        message = '${decoded['detail'] ?? decoded['message'] ?? message}';
      }
    } catch (_) {
      if (response.body.isNotEmpty) message = response.body;
    }
    throw Exception(message);
  }
}
