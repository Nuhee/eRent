import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:erent_mobile/model/chat.dart';
import 'package:erent_mobile/model/conversation.dart';
import 'package:erent_mobile/model/search_result.dart';
import 'package:erent_mobile/providers/base_provider.dart';

class ChatProvider extends BaseProvider<Chat> {
  ChatProvider() : super('Chat');

  @override
  Chat fromJson(dynamic json) {
    return Chat.fromJson(json as Map<String, dynamic>);
  }

  /// Get all conversations for a user
  Future<List<Conversation>> getConversations(int userId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/conversations/$userId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body) as List;
      return data.map((e) => Conversation.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception("Failed to load conversations");
    }
  }

  /// Get messages between two users
  Future<SearchResult<Chat>> getConversationMessages(
    int userId,
    int otherUserId, {
    int page = 0,
    int pageSize = 50,
  }) async {
    var url = "${BaseProvider.baseUrl}$endpoint/conversation/$userId/$otherUserId?page=$page&pageSize=$pageSize";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      var result = SearchResult<Chat>();
      result.totalCount = data['totalCount'];
      result.items = List<Chat>.from(
        (data['items'] as List).map((e) => Chat.fromJson(e as Map<String, dynamic>)),
      );
      return result;
    } else {
      throw Exception("Failed to load messages");
    }
  }

  /// Send a message
  Future<Chat> sendMessage({
    required int senderId,
    required int receiverId,
    required String message,
  }) async {
    var request = {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
    };
    return await insert(request);
  }

  /// Mark a single message as read
  Future<bool> markAsRead(int chatId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/$chatId/read";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);

    if (response.statusCode < 299) {
      return true;
    }
    return false;
  }

  /// Mark all messages in a conversation as read
  Future<bool> markConversationAsRead(int senderId, int receiverId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/mark-conversation-read?senderId=$senderId&receiverId=$receiverId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);

    if (response.statusCode < 299) {
      return true;
    }
    return false;
  }

  /// Get unread message count for a user
  Future<int> getUnreadCount(int userId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/unread-count?userId=$userId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      return int.parse(response.body);
    }
    return 0;
  }
}
