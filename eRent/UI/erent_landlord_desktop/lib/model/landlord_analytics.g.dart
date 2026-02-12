// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'landlord_analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LandlordAnalytics _$LandlordAnalyticsFromJson(
  Map<String, dynamic> json,
) => LandlordAnalytics(
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

Map<String, dynamic> _$LandlordAnalyticsToJson(LandlordAnalytics instance) =>
    <String, dynamic>{
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
