// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viewing_appointment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ViewingAppointment _$ViewingAppointmentFromJson(Map<String, dynamic> json) =>
    ViewingAppointment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      propertyId: (json['propertyId'] as num?)?.toInt() ?? 0,
      propertyTitle: json['propertyTitle'] as String? ?? '',
      propertyAddress: json['propertyAddress'] as String? ?? '',
      tenantId: (json['tenantId'] as num?)?.toInt() ?? 0,
      tenantName: json['tenantName'] as String? ?? '',
      landlordId: (json['landlordId'] as num?)?.toInt() ?? 0,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: (json['status'] as num?)?.toInt() ?? 0,
      statusName: json['statusName'] as String? ?? '',
      tenantNote: json['tenantNote'] as String?,
      landlordNote: json['landlordNote'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ViewingAppointmentToJson(ViewingAppointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'propertyId': instance.propertyId,
      'propertyTitle': instance.propertyTitle,
      'propertyAddress': instance.propertyAddress,
      'tenantId': instance.tenantId,
      'tenantName': instance.tenantName,
      'landlordId': instance.landlordId,
      'appointmentDate': instance.appointmentDate.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'status': instance.status,
      'statusName': instance.statusName,
      'tenantNote': instance.tenantNote,
      'landlordNote': instance.landlordNote,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
