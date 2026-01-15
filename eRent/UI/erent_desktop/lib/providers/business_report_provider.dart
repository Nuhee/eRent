import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:erent_desktop/model/business_report.dart';
import 'package:erent_desktop/providers/base_provider.dart';

class BusinessReportProvider extends BaseProvider<BusinessReport> {
  BusinessReportProvider() : super("BusinessReport");

  @override
  BusinessReport fromJson(dynamic json) {
    return BusinessReport.fromJson(json);
  }

  Future<BusinessReport> getReport() async {
    var url = "${BaseProvider.baseUrl}$endpoint";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);
    if (isValidResponse(response)) {
      if (response.body.isEmpty) {
        throw Exception("Empty response");
      }
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Unknown error");
    }
  }
}

