import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:erent_mobile/model/analytics.dart';
import 'package:erent_mobile/providers/auth_provider.dart';

class AnalyticsProvider with ChangeNotifier {
  static String? baseUrl;
  String endpoint = "Analytics";

  AnalyticsProvider() {
    baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:5130/",
    );
  }

  Future<Analytics> getAnalytics() async {
    var url = "$baseUrl$endpoint";
    var uri = Uri.parse(url);
    var headers = _createHeaders();

    var response = await http.get(uri, headers: headers);
    if (_isValidResponse(response)) {
      if (response.body.isEmpty) {
        throw Exception("Empty response");
      }
      var data = jsonDecode(response.body);
      return Analytics.fromJson(data as Map<String, dynamic>);
    } else {
      throw Exception("Unknown error");
    }
  }

  bool _isValidResponse(http.Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Please check your credentials and try again.");
    } else {
      print(response.body);
      throw Exception("Something went wrong, please try again later!");
    }
  }

  Map<String, String> _createHeaders() {
    String username = AuthProvider.username ?? "";
    String password = AuthProvider.password ?? "";

    String basicAuth =
        "Basic ${base64Encode(utf8.encode('$username:$password'))}";

    var headers = {
      "Content-Type": "application/json",
      "Authorization": basicAuth,
    };

    return headers;
  }
}
