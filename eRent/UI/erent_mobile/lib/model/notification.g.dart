// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: (json['type'] as num?)?.toInt() ?? 0,
      typeName: json['typeName'] as String? ?? '',
      referenceId: (json['referenceId'] as num?)?.toInt(),
      referenceType: json['referenceType'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AppNotificationToJson(AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'message': instance.message,
      'type': instance.type,
      'typeName': instance.typeName,
      'referenceId': instance.referenceId,
      'referenceType': instance.referenceType,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
    };
