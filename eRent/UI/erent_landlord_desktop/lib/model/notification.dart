import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class AppNotification {
  final int id;
  final int userId;
  final String title;
  final String message;
  final int type;
  final String typeName;
  final int? referenceId;
  final String? referenceType;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    this.id = 0,
    this.userId = 0,
    this.title = '',
    this.message = '',
    this.type = 0,
    this.typeName = '',
    this.referenceId,
    this.referenceType,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);
}
