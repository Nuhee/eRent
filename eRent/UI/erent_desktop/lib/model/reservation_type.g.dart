// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReservationType _$ReservationTypeFromJson(Map<String, dynamic> json) =>
    ReservationType(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$ReservationTypeToJson(ReservationType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
    };
