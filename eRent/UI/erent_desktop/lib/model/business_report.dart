import 'package:json_annotation/json_annotation.dart';

part 'business_report.g.dart';

@JsonSerializable()
class BusinessReport {
  final double totalRevenue;
  final int totalReservations;
  final int activeUsers;
  final int totalParkingSpots;
  final int activeParkingSpots;
  final double averageReservationPrice;
  final List<RevenueByType> revenueByReservationType;
  final List<ReservationCountByType> reservationsByType;
  final List<RevenueByZone> revenueByZone;
  final List<ReservationCountByZone> reservationsByZone;
  final List<PopularZone> mostPopularZones;
  final List<RecentReservation> recentReservations;

  BusinessReport({
    this.totalRevenue = 0.0,
    this.totalReservations = 0,
    this.activeUsers = 0,
    this.totalParkingSpots = 0,
    this.activeParkingSpots = 0,
    this.averageReservationPrice = 0.0,
    this.revenueByReservationType = const [],
    this.reservationsByType = const [],
    this.revenueByZone = const [],
    this.reservationsByZone = const [],
    this.mostPopularZones = const [],
    this.recentReservations = const [],
  });

  factory BusinessReport.fromJson(Map<String, dynamic> json) => _$BusinessReportFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessReportToJson(this);
}

@JsonSerializable()
class RevenueByType {
  final String reservationTypeName;
  final double revenue;
  final int count;

  RevenueByType({
    this.reservationTypeName = '',
    this.revenue = 0.0,
    this.count = 0,
  });

  factory RevenueByType.fromJson(Map<String, dynamic> json) => _$RevenueByTypeFromJson(json);
  Map<String, dynamic> toJson() => _$RevenueByTypeToJson(this);
}

@JsonSerializable()
class ReservationCountByType {
  final String reservationTypeName;
  final int count;

  ReservationCountByType({
    this.reservationTypeName = '',
    this.count = 0,
  });

  factory ReservationCountByType.fromJson(Map<String, dynamic> json) => _$ReservationCountByTypeFromJson(json);
  Map<String, dynamic> toJson() => _$ReservationCountByTypeToJson(this);
}

@JsonSerializable()
class RevenueByZone {
  final String zoneName;
  final double revenue;
  final int count;

  RevenueByZone({
    this.zoneName = '',
    this.revenue = 0.0,
    this.count = 0,
  });

  factory RevenueByZone.fromJson(Map<String, dynamic> json) => _$RevenueByZoneFromJson(json);
  Map<String, dynamic> toJson() => _$RevenueByZoneToJson(this);
}

@JsonSerializable()
class ReservationCountByZone {
  final String zoneName;
  final int count;

  ReservationCountByZone({
    this.zoneName = '',
    this.count = 0,
  });

  factory ReservationCountByZone.fromJson(Map<String, dynamic> json) => _$ReservationCountByZoneFromJson(json);
  Map<String, dynamic> toJson() => _$ReservationCountByZoneToJson(this);
}

@JsonSerializable()
class PopularZone {
  final String zoneName;
  final int reservationCount;
  final double totalRevenue;

  PopularZone({
    this.zoneName = '',
    this.reservationCount = 0,
    this.totalRevenue = 0.0,
  });

  factory PopularZone.fromJson(Map<String, dynamic> json) => _$PopularZoneFromJson(json);
  Map<String, dynamic> toJson() => _$PopularZoneToJson(this);
}

@JsonSerializable()
class RecentReservation {
  final int id;
  final String parkingSpotNumber;
  final String zoneName;
  final String reservationTypeName;
  final String userFullName;
  final double finalPrice;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  RecentReservation({
    this.id = 0,
    this.parkingSpotNumber = '',
    this.zoneName = '',
    this.reservationTypeName = '',
    this.userFullName = '',
    this.finalPrice = 0.0,
    this.startDate,
    this.endDate,
    required this.createdAt,
  });

  factory RecentReservation.fromJson(Map<String, dynamic> json) => _$RecentReservationFromJson(json);
  Map<String, dynamic> toJson() => _$RecentReservationToJson(this);
}

