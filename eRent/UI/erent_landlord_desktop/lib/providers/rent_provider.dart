import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:erent_landlord_desktop/model/rent.dart';
import 'package:erent_landlord_desktop/providers/base_provider.dart';

class RentProvider extends BaseProvider<Rent> {
  RentProvider() : super('Rent');

  @override
  Rent fromJson(dynamic json) {
    return Rent.fromJson(json as Map<String, dynamic>);
  }

  /// Cancel a rent (available for Pending or Accepted status)
  Future<Rent?> cancel(int id) async {
    var url = "${BaseProvider.baseUrl}$endpoint/$id/cancel";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to cancel rent");
    }
  }

  /// Reject a rent (available for Pending status only - landlord action)
  Future<Rent?> reject(int id) async {
    var url = "${BaseProvider.baseUrl}$endpoint/$id/reject";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to reject rent");
    }
  }

  /// Accept a rent (available for Pending status only - landlord action)
  Future<Rent?> accept(int id) async {
    var url = "${BaseProvider.baseUrl}$endpoint/$id/accept";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to accept rent");
    }
  }

  /// Mark a rent as paid (available for Accepted status only)
  Future<Rent?> pay(int id) async {
    var url = "${BaseProvider.baseUrl}$endpoint/$id/pay";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to mark rent as paid");
    }
  }
}
