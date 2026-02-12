import 'package:json_annotation/json_annotation.dart';

part 'analytics.g.dart';

@JsonSerializable()
class Analytics {
  final double totalRevenue;
  final double monthlyRevenue;
  final double averageRentPrice;
  final List<RevenueByPropertyType> revenueByPropertyType;
  final List<RevenueByCity> revenueByCity;
  final List<MonthlyRevenueData> monthlyRevenueTrend;
  final int totalRents;
  final int activeRents;
  final int pendingRents;
  final int paidRents;
  final int cancelledRents;
  final int rejectedRents;
  final int acceptedRents;
  final int dailyRentals;
  final int monthlyRentals;
  final double averageRentalDuration;
  final double occupancyRate;
  final int totalProperties;
  final int activeProperties;
  final int inactiveProperties;
  final List<PropertyCountByType> propertiesByType;
  final List<PropertyCountByCity> propertiesByCity;
  final List<AveragePriceByType> averagePriceByPropertyType;
  final int totalUsers;
  final int activeUsers;
  final int totalLandlords;
  final int totalTenants;
  final int totalAdmins;
  final List<MonthlyUserGrowth> monthlyUserGrowth;
  final int totalReviews;
  final double averageRating;
  final int rating5Count;
  final int rating4Count;
  final int rating3Count;
  final int rating2Count;
  final int rating1Count;
  final List<MonthlyPropertyGrowth> monthlyPropertyGrowth;
  final List<MonthlyRentGrowth> monthlyRentGrowth;

  const Analytics({
    this.totalRevenue = 0.0,
    this.monthlyRevenue = 0.0,
    this.averageRentPrice = 0.0,
    this.revenueByPropertyType = const [],
    this.revenueByCity = const [],
    this.monthlyRevenueTrend = const [],
    this.totalRents = 0,
    this.activeRents = 0,
    this.pendingRents = 0,
    this.paidRents = 0,
    this.cancelledRents = 0,
    this.rejectedRents = 0,
    this.acceptedRents = 0,
    this.dailyRentals = 0,
    this.monthlyRentals = 0,
    this.averageRentalDuration = 0.0,
    this.occupancyRate = 0.0,
    this.totalProperties = 0,
    this.activeProperties = 0,
    this.inactiveProperties = 0,
    this.propertiesByType = const [],
    this.propertiesByCity = const [],
    this.averagePriceByPropertyType = const [],
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.totalLandlords = 0,
    this.totalTenants = 0,
    this.totalAdmins = 0,
    this.monthlyUserGrowth = const [],
    this.totalReviews = 0,
    this.averageRating = 0.0,
    this.rating5Count = 0,
    this.rating4Count = 0,
    this.rating3Count = 0,
    this.rating2Count = 0,
    this.rating1Count = 0,
    this.monthlyPropertyGrowth = const [],
    this.monthlyRentGrowth = const [],
  });

  factory Analytics.fromJson(Map<String, dynamic> json) => _$AnalyticsFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticsToJson(this);
}

@JsonSerializable()
class RevenueByPropertyType {
  final String propertyTypeName;
  final double revenue;
  final int rentCount;

  const RevenueByPropertyType({
    this.propertyTypeName = '',
    this.revenue = 0.0,
    this.rentCount = 0,
  });

  factory RevenueByPropertyType.fromJson(Map<String, dynamic> json) => _$RevenueByPropertyTypeFromJson(json);
  Map<String, dynamic> toJson() => _$RevenueByPropertyTypeToJson(this);
}

@JsonSerializable()
class RevenueByCity {
  final String cityName;
  final double revenue;
  final int rentCount;

  const RevenueByCity({
    this.cityName = '',
    this.revenue = 0.0,
    this.rentCount = 0,
  });

  factory RevenueByCity.fromJson(Map<String, dynamic> json) => _$RevenueByCityFromJson(json);
  Map<String, dynamic> toJson() => _$RevenueByCityToJson(this);
}

@JsonSerializable()
class MonthlyRevenueData {
  final String month;
  final double revenue;
  final int rentCount;

  const MonthlyRevenueData({
    this.month = '',
    this.revenue = 0.0,
    this.rentCount = 0,
  });

  factory MonthlyRevenueData.fromJson(Map<String, dynamic> json) => _$MonthlyRevenueDataFromJson(json);
  Map<String, dynamic> toJson() => _$MonthlyRevenueDataToJson(this);
}

@JsonSerializable()
class PropertyCountByType {
  final String propertyTypeName;
  final int count;
  final int activeCount;

  const PropertyCountByType({
    this.propertyTypeName = '',
    this.count = 0,
    this.activeCount = 0,
  });

  factory PropertyCountByType.fromJson(Map<String, dynamic> json) => _$PropertyCountByTypeFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyCountByTypeToJson(this);
}

@JsonSerializable()
class PropertyCountByCity {
  final String cityName;
  final int count;
  final int activeCount;

  const PropertyCountByCity({
    this.cityName = '',
    this.count = 0,
    this.activeCount = 0,
  });

  factory PropertyCountByCity.fromJson(Map<String, dynamic> json) => _$PropertyCountByCityFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyCountByCityToJson(this);
}

@JsonSerializable()
class AveragePriceByType {
  final String propertyTypeName;
  final double averagePricePerMonth;
  final double? averagePricePerDay;

  const AveragePriceByType({
    this.propertyTypeName = '',
    this.averagePricePerMonth = 0.0,
    this.averagePricePerDay,
  });

  factory AveragePriceByType.fromJson(Map<String, dynamic> json) => _$AveragePriceByTypeFromJson(json);
  Map<String, dynamic> toJson() => _$AveragePriceByTypeToJson(this);
}

@JsonSerializable()
class MonthlyUserGrowth {
  final String month;
  final int newUsers;
  final int totalUsers;

  const MonthlyUserGrowth({
    this.month = '',
    this.newUsers = 0,
    this.totalUsers = 0,
  });

  factory MonthlyUserGrowth.fromJson(Map<String, dynamic> json) => _$MonthlyUserGrowthFromJson(json);
  Map<String, dynamic> toJson() => _$MonthlyUserGrowthToJson(this);
}

@JsonSerializable()
class MonthlyPropertyGrowth {
  final String month;
  final int newProperties;
  final int totalProperties;

  const MonthlyPropertyGrowth({
    this.month = '',
    this.newProperties = 0,
    this.totalProperties = 0,
  });

  factory MonthlyPropertyGrowth.fromJson(Map<String, dynamic> json) => _$MonthlyPropertyGrowthFromJson(json);
  Map<String, dynamic> toJson() => _$MonthlyPropertyGrowthToJson(this);
}

@JsonSerializable()
class MonthlyRentGrowth {
  final String month;
  final int newRents;
  final int totalRents;

  const MonthlyRentGrowth({
    this.month = '',
    this.newRents = 0,
    this.totalRents = 0,
  });

  factory MonthlyRentGrowth.fromJson(Map<String, dynamic> json) => _$MonthlyRentGrowthFromJson(json);
  Map<String, dynamic> toJson() => _$MonthlyRentGrowthToJson(this);
}
