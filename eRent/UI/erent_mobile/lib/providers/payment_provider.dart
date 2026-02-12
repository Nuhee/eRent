import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:erent_mobile/providers/auth_provider.dart';
import 'package:erent_mobile/providers/base_provider.dart';

class PaymentProvider with ChangeNotifier {
  Map<String, String> _createHeaders() {
    final username = AuthProvider.username ?? "";
    final password = AuthProvider.password ?? "";
    final basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";
    return {
      'Content-Type': 'application/json',
      'Authorization': basicAuth,
    };
  }

  /// Creates a PaymentIntent via the backend API. Returns map with
  /// paymentId, clientSecret, ephemeralKey, customerId.
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required String customerName,
    required String customerEmail,
    required String billingAddress,
    required String billingCity,
    required String billingState,
    required String billingCountry,
    required String billingZipCode,
  }) async {
    final baseUrl = BaseProvider.baseUrl;
    final headers = _createHeaders();

    final response = await http.post(
      Uri.parse('${baseUrl}Payment/create-payment-intent'),
      headers: headers,
      body: jsonEncode({
        'amount': amount,
        'currency': currency,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'billingAddress': billingAddress,
        'billingCity': billingCity,
        'billingState': billingState,
        'billingCountry': billingCountry,
        'billingZipCode': billingZipCode,
      }),
    );

    if (response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(
          errorBody['error'] ?? 'Failed to create payment intent');
    }
  }

  /// Confirms the payment on the backend and links it to the given rent.
  Future<void> confirmPayment(int paymentId, int rentId) async {
    final baseUrl = BaseProvider.baseUrl;
    final headers = _createHeaders();

    final response = await http.put(
      Uri.parse('${baseUrl}Payment/$paymentId/confirm'),
      headers: headers,
      body: jsonEncode({'rentId': rentId}),
    );

    if (response.statusCode >= 300) {
      print('Warning: Failed to confirm payment on backend: ${response.body}');
    }
  }
}
