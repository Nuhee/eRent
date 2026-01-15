// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BusinessReport _$BusinessReportFromJson(Map<String, dynamic> json) =>
    BusinessReport(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalReservations: (json['totalReservations'] as num?)?.toInt() ?? 0,
      activeUsers: (json['activeUsers'] as num?)?.toInt() ?? 0,
      totalParkingSpots: (json['totalParkingSpots'] as num?)?.toInt() ?? 0,
      activeParkingSpots: (json['activeParkingSpots'] as num?)?.toInt() ?? 0,
      averageReservationPrice:
          (json['averageReservationPrice'] as num?)?.toDouble() ?? 0.0,
      revenueByReservationType:
          (json['revenueByReservationType'] as List<dynamic>?)
              ?.map((e) => RevenueByType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      reservationsByType:
          (json['reservationsByType'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ReservationCountByType.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      revenueByZone:
          (json['revenueByZone'] as List<dynamic>?)
              ?.map((e) => RevenueByZone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      reservationsByZone:
          (json['reservationsByZone'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ReservationCountByZone.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      mostPopularZones:
          (json['mostPopularZones'] as List<dynamic>?)
              ?.map((e) => PopularZone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recentReservations:
          (json['recentReservations'] as List<dynamic>?)
              ?.map(
                (e) => RecentReservation.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$BusinessReportToJson(BusinessReport instance) =>
    <String, dynamic>{
      'totalRevenue': instance.totalRevenue,
      'totalReservations': instance.totalReservations,
      'activeUsers': instance.activeUsers,
      'totalParkingSpots': instance.totalParkingSpots,
      'activeParkingSpots': instance.activeParkingSpots,
      'averageReservationPrice': instance.averageReservationPrice,
      'revenueByReservationType': instance.revenueByReservationType,
      'reservationsByType': instance.reservationsByType,
      'revenueByZone': instance.revenueByZone,
      'reservationsByZone': instance.reservationsByZone,
      'mostPopularZones': instance.mostPopularZones,
      'recentReservations': instance.recentReservations,
    };

RevenueByType _$RevenueByTypeFromJson(Map<String, dynamic> json) =>
    RevenueByType(
      reservationTypeName: json['reservationTypeName'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RevenueByTypeToJson(RevenueByType instance) =>
    <String, dynamic>{
      'reservationTypeName': instance.reservationTypeName,
      'revenue': instance.revenue,
      'count': instance.count,
    };

ReservationCountByType _$ReservationCountByTypeFromJson(
  Map<String, dynamic> json,
) => ReservationCountByType(
  reservationTypeName: json['reservationTypeName'] as String? ?? '',
  count: (json['count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ReservationCountByTypeToJson(
  ReservationCountByType instance,
) => <String, dynamic>{
  'reservationTypeName': instance.reservationTypeName,
  'count': instance.count,
};

RevenueByZone _$RevenueByZoneFromJson(Map<String, dynamic> json) =>
    RevenueByZone(
      zoneName: json['zoneName'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RevenueByZoneToJson(RevenueByZone instance) =>
    <String, dynamic>{
      'zoneName': instance.zoneName,
      'revenue': instance.revenue,
      'count': instance.count,
    };

ReservationCountByZone _$ReservationCountByZoneFromJson(
  Map<String, dynamic> json,
) => ReservationCountByZone(
  zoneName: json['zoneName'] as String? ?? '',
  count: (json['count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ReservationCountByZoneToJson(
  ReservationCountByZone instance,
) => <String, dynamic>{'zoneName': instance.zoneName, 'count': instance.count};

PopularZone _$PopularZoneFromJson(Map<String, dynamic> json) => PopularZone(
  zoneName: json['zoneName'] as String? ?? '',
  reservationCount: (json['reservationCount'] as num?)?.toInt() ?? 0,
  totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$PopularZoneToJson(PopularZone instance) =>
    <String, dynamic>{
      'zoneName': instance.zoneName,
      'reservationCount': instance.reservationCount,
      'totalRevenue': instance.totalRevenue,
    };

RecentReservation _$RecentReservationFromJson(Map<String, dynamic> json) =>
    RecentReservation(
      id: (json['id'] as num?)?.toInt() ?? 0,
      parkingSpotNumber: json['parkingSpotNumber'] as String? ?? '',
      zoneName: json['zoneName'] as String? ?? '',
      reservationTypeName: json['reservationTypeName'] as String? ?? '',
      userFullName: json['userFullName'] as String? ?? '',
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0.0,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RecentReservationToJson(RecentReservation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parkingSpotNumber': instance.parkingSpotNumber,
      'zoneName': instance.zoneName,
      'reservationTypeName': instance.reservationTypeName,
      'userFullName': instance.userFullName,
      'finalPrice': instance.finalPrice,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
