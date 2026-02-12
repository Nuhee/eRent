import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:erent_landlord_desktop/model/viewing_appointment.dart';
import 'package:erent_landlord_desktop/providers/base_provider.dart';

class ViewingAppointmentProvider extends BaseProvider<ViewingAppointment> {
  ViewingAppointmentProvider() : super('ViewingAppointment');

  @override
  ViewingAppointment fromJson(dynamic json) {
    return ViewingAppointment.fromJson(json as Map<String, dynamic>);
  }

  /// Approve a viewing appointment (landlord action)
  Future<ViewingAppointment?> approve(int id, {String? landlordNote}) async {
    var url = "${BaseProvider.baseUrl}$endpoint/$id/approve";
    if (landlordNote != null && landlordNote.isNotEmpty) {
      url += "?landlordNote=${Uri.encodeComponent(landlordNote)}";
    }
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to approve viewing appointment");
    }
  }

  /// Reject a viewing appointment (landlord action)
  Future<ViewingAppointment?> reject(int id, {String? landlordNote}) async {
    var url = "${BaseProvider.baseUrl}$endpoint/$id/reject";
    if (landlordNote != null && landlordNote.isNotEmpty) {
      url += "?landlordNote=${Uri.encodeComponent(landlordNote)}";
    }
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to reject viewing appointment");
    }
  }

  /// Cancel a viewing appointment
  Future<ViewingAppointment?> cancel(int id) async {
    var url = "${BaseProvider.baseUrl}$endpoint/$id/cancel";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);

    if (isValidResponse(response)) {
      if (response.body.isEmpty) return null;
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to cancel viewing appointment");
    }
  }
}
