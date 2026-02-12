// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Analytics _$AnalyticsFromJson(Map<String, dynamic> json) => Analytics(
  totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
  monthlyRevenue: (json['monthlyRevenue'] as num?)?.toDouble() ?? 0.0,
  averageRentPrice: (json['averageRentPrice'] as num?)?.toDouble() ?? 0.0,
  revenueByPropertyType:
      (json['revenueByPropertyType'] as List<dynamic>?)
          ?.map(
            (e) => RevenueByPropertyType.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  revenueByCity:
      (json['revenueByCity'] as List<dynamic>?)
          ?.map((e) => RevenueByCity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  monthlyRevenueTrend:
      (json['monthlyRevenueTrend'] as List<dynamic>?)
          ?.map((e) => MonthlyRevenueData.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  totalRents: (json['totalRents'] as num?)?.toInt() ?? 0,
  activeRents: (json['activeRents'] as num?)?.toInt() ?? 0,
  pendingRents: (json['pendingRents'] as num?)?.toInt() ?? 0,
  paidRents: (json['paidRents'] as num?)?.toInt() ?? 0,
  cancelledRents: (json['cancelledRents'] as num?)?.toInt() ?? 0,
  rejectedRents: (json['rejectedRents'] as num?)?.toInt() ?? 0,
  acceptedRents: (json['acceptedRents'] as num?)?.toInt() ?? 0,
  dailyRentals: (json['dailyRentals'] as num?)?.toInt() ?? 0,
  monthlyRentals: (json['monthlyRentals'] as num?)?.toInt() ?? 0,
  averageRentalDuration:
      (json['averageRentalDuration'] as num?)?.toDouble() ?? 0.0,
  occupancyRate: (json['occupancyRate'] as num?)?.toDouble() ?? 0.0,
  totalProperties: (json['totalProperties'] as num?)?.toInt() ?? 0,
  activeProperties: (json['activeProperties'] as num?)?.toInt() ?? 0,
  inactiveProperties: (json['inactiveProperties'] as num?)?.toInt() ?? 0,
  propertiesByType:
      (json['propertiesByType'] as List<dynamic>?)
          ?.map((e) => PropertyCountByType.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  propertiesByCity:
      (json['propertiesByCity'] as List<dynamic>?)
          ?.map((e) => PropertyCountByCity.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  averagePriceByPropertyType:
      (json['averagePriceByPropertyType'] as List<dynamic>?)
          ?.map((e) => AveragePriceByType.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
  activeUsers: (json['activeUsers'] as num?)?.toInt() ?? 0,
  totalLandlords: (json['totalLandlords'] as num?)?.toInt() ?? 0,
  totalTenants: (json['totalTenants'] as num?)?.toInt() ?? 0,
  totalAdmins: (json['totalAdmins'] as num?)?.toInt() ?? 0,
  monthlyUserGrowth:
      (json['monthlyUserGrowth'] as List<dynamic>?)
          ?.map((e) => MonthlyUserGrowth.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
  averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
  rating5Count: (json['rating5Count'] as num?)?.toInt() ?? 0,
  rating4Count: (json['rating4Count'] as num?)?.toInt() ?? 0,
  rating3Count: (json['rating3Count'] as num?)?.toInt() ?? 0,
  rating2Count: (json['rating2Count'] as num?)?.toInt() ?? 0,
  rating1Count: (json['rating1Count'] as num?)?.toInt() ?? 0,
  monthlyPropertyGrowth:
      (json['monthlyPropertyGrowth'] as List<dynamic>?)
          ?.map(
            (e) => MonthlyPropertyGrowth.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  monthlyRentGrowth:
      (json['monthlyRentGrowth'] as List<dynamic>?)
          ?.map((e) => MonthlyRentGrowth.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$AnalyticsToJson(Analytics instance) => <String, dynamic>{
  'totalRevenue': instance.totalRevenue,
  'monthlyRevenue': instance.monthlyRevenue,
  'averageRentPrice': instance.averageRentPrice,
  'revenueByPropertyType': instance.revenueByPropertyType,
  'revenueByCity': instance.revenueByCity,
  'monthlyRevenueTrend': instance.monthlyRevenueTrend,
  'totalRents': instance.totalRents,
  'activeRents': instance.activeRents,
  'pendingRents': instance.pendingRents,
  'paidRents': instance.paidRents,
  'cancelledRents': instance.cancelledRents,
  'rejectedRents': instance.rejectedRents,
  'acceptedRents': instance.acceptedRents,
  'dailyRentals': instance.dailyRentals,
  'monthlyRentals': instance.monthlyRentals,
  'averageRentalDuration': instance.averageRentalDuration,
  'occupancyRate': instance.occupancyRate,
  'totalProperties': instance.totalProperties,
  'activeProperties': instance.activeProperties,
  'inactiveProperties': instance.inactiveProperties,
  'propertiesByType': instance.propertiesByType,
  'propertiesByCity': instance.propertiesByCity,
  'averagePriceByPropertyType': instance.averagePriceByPropertyType,
  'totalUsers': instance.totalUsers,
  'activeUsers': instance.activeUsers,
  'totalLandlords': instance.totalLandlords,
  'totalTenants': instance.totalTenants,
  'totalAdmins': instance.totalAdmins,
  'monthlyUserGrowth': instance.monthlyUserGrowth,
  'totalReviews': instance.totalReviews,
  'averageRating': instance.averageRating,
  'rating5Count': instance.rating5Count,
  'rating4Count': instance.rating4Count,
  'rating3Count': instance.rating3Count,
  'rating2Count': instance.rating2Count,
  'rating1Count': instance.rating1Count,
  'monthlyPropertyGrowth': instance.monthlyPropertyGrowth,
  'monthlyRentGrowth': instance.monthlyRentGrowth,
};

RevenueByPropertyType _$RevenueByPropertyTypeFromJson(
  Map<String, dynamic> json,
) => RevenueByPropertyType(
  propertyTypeName: json['propertyTypeName'] as String? ?? '',
  revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
  rentCount: (json['rentCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RevenueByPropertyTypeToJson(
  RevenueByPropertyType instance,
) => <String, dynamic>{
  'propertyTypeName': instance.propertyTypeName,
  'revenue': instance.revenue,
  'rentCount': instance.rentCount,
};

RevenueByCity _$RevenueByCityFromJson(Map<String, dynamic> json) =>
    RevenueByCity(
      cityName: json['cityName'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      rentCount: (json['rentCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$RevenueByCityToJson(RevenueByCity instance) =>
    <String, dynamic>{
      'cityName': instance.cityName,
      'revenue': instance.revenue,
      'rentCount': instance.rentCount,
    };

MonthlyRevenueData _$MonthlyRevenueDataFromJson(Map<String, dynamic> json) =>
    MonthlyRevenueData(
      month: json['month'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      rentCount: (json['rentCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MonthlyRevenueDataToJson(MonthlyRevenueData instance) =>
    <String, dynamic>{
      'month': instance.month,
      'revenue': instance.revenue,
      'rentCount': instance.rentCount,
    };

PropertyCountByType _$PropertyCountByTypeFromJson(Map<String, dynamic> json) =>
    PropertyCountByType(
      propertyTypeName: json['propertyTypeName'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      activeCount: (json['activeCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PropertyCountByTypeToJson(
  PropertyCountByType instance,
) => <String, dynamic>{
  'propertyTypeName': instance.propertyTypeName,
  'count': instance.count,
  'activeCount': instance.activeCount,
};

PropertyCountByCity _$PropertyCountByCityFromJson(Map<String, dynamic> json) =>
    PropertyCountByCity(
      cityName: json['cityName'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      activeCount: (json['activeCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PropertyCountByCityToJson(
  PropertyCountByCity instance,
) => <String, dynamic>{
  'cityName': instance.cityName,
  'count': instance.count,
  'activeCount': instance.activeCount,
};

AveragePriceByType _$AveragePriceByTypeFromJson(Map<String, dynamic> json) =>
    AveragePriceByType(
      propertyTypeName: json['propertyTypeName'] as String? ?? '',
      averagePricePerMonth:
          (json['averagePricePerMonth'] as num?)?.toDouble() ?? 0.0,
      averagePricePerDay: (json['averagePricePerDay'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AveragePriceByTypeToJson(AveragePriceByType instance) =>
    <String, dynamic>{
      'propertyTypeName': instance.propertyTypeName,
      'averagePricePerMonth': instance.averagePricePerMonth,
      'averagePricePerDay': instance.averagePricePerDay,
    };

MonthlyUserGrowth _$MonthlyUserGrowthFromJson(Map<String, dynamic> json) =>
    MonthlyUserGrowth(
      month: json['month'] as String? ?? '',
      newUsers: (json['newUsers'] as num?)?.toInt() ?? 0,
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MonthlyUserGrowthToJson(MonthlyUserGrowth instance) =>
    <String, dynamic>{
      'month': instance.month,
      'newUsers': instance.newUsers,
      'totalUsers': instance.totalUsers,
    };

MonthlyPropertyGrowth _$MonthlyPropertyGrowthFromJson(
  Map<String, dynamic> json,
) => MonthlyPropertyGrowth(
  month: json['month'] as String? ?? '',
  newProperties: (json['newProperties'] as num?)?.toInt() ?? 0,
  totalProperties: (json['totalProperties'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MonthlyPropertyGrowthToJson(
  MonthlyPropertyGrowth instance,
) => <String, dynamic>{
  'month': instance.month,
  'newProperties': instance.newProperties,
  'totalProperties': instance.totalProperties,
};

MonthlyRentGrowth _$MonthlyRentGrowthFromJson(Map<String, dynamic> json) =>
    MonthlyRentGrowth(
      month: json['month'] as String? ?? '',
      newRents: (json['newRents'] as num?)?.toInt() ?? 0,
      totalRents: (json['totalRents'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MonthlyRentGrowthToJson(MonthlyRentGrowth instance) =>
    <String, dynamic>{
      'month': instance.month,
      'newRents': instance.newRents,
      'totalRents': instance.totalRents,
    };
