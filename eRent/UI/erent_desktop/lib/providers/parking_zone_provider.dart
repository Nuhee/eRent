import 'dart:convert';
import 'package:erent_desktop/model/parking_zone.dart';
import 'package:erent_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'package:erent_desktop/providers/auth_provider.dart';

class ParkingZoneProvider extends BaseProvider<ParkingZone> {
  ParkingZoneProvider() : super("ParkingZone");

  @override
  ParkingZone fromJson(dynamic json) {
    return ParkingZone.fromJson(json);
  }

  Future<ParkingZone> createWithSpots(Map<String, dynamic> request) async {
    var url = "${BaseProvider.baseUrl}ParkingZone/create-with-spots";
    var uri = Uri.parse(url);
    var headers = _createHeaders();

    var jsonRequest = jsonEncode(request);
    var response = await http.post(uri, headers: headers, body: jsonRequest);

    if (_isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
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

