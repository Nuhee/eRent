import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:erent_mobile/model/notification.dart';
import 'package:erent_mobile/model/search_result.dart';
import 'package:erent_mobile/providers/auth_provider.dart';
import 'package:erent_mobile/providers/base_provider.dart';

class NotificationProvider extends BaseProvider<AppNotification> {
  NotificationProvider() : super('Notification');

  @override
  AppNotification fromJson(dynamic json) {
    return AppNotification.fromJson(json as Map<String, dynamic>);
  }

  /// Gets the unread notification count for a user.
  Future<int> getUnreadCount(int userId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/unread-count/$userId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return data['count'] as int;
    }
    return 0;
  }

  /// Marks a single notification as read.
  Future<bool> markAsRead(int id) async {
    var url = "${BaseProvider.baseUrl}$endpoint/$id/mark-read";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);
    return response.statusCode < 300;
  }

  /// Marks all notifications as read for a user.
  Future<bool> markAllAsRead(int userId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/mark-all-read/$userId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);
    return response.statusCode < 300;
  }
}
