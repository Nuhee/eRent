import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:erent_mobile/model/property.dart';
import 'package:erent_mobile/providers/base_provider.dart';

class PropertyProvider extends BaseProvider<Property> {
  PropertyProvider() : super('Property');

  @override
  Property fromJson(dynamic json) {
    return Property.fromJson(json as Map<String, dynamic>);
  }

  Future<List<Property>> getRecommended(int userId, {int count = 5}) async {
    try {
      final url = '${BaseProvider.baseUrl}$endpoint/recommended/$userId?count=$count';
      final uri = Uri.parse(url);
      final headers = createHeaders();

      final response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        if (response.body.isEmpty) return [];
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recommended properties: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting recommended properties: $e');
    }
  }
}
