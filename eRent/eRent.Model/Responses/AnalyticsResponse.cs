using System;
using System.Collections.Generic;

namespace eRent.Model.Responses
{
    public class AnalyticsResponse
    {
        // Revenue Metrics
        public decimal TotalRevenue { get; set; }
        public decimal MonthlyRevenue { get; set; }
        public decimal AverageRentPrice { get; set; }
        public List<RevenueByPropertyType> RevenueByPropertyType { get; set; } = new List<RevenueByPropertyType>();
        public List<RevenueByCity> RevenueByCity { get; set; } = new List<RevenueByCity>();
        public List<MonthlyRevenueData> MonthlyRevenueTrend { get; set; } = new List<MonthlyRevenueData>();

        // Rent Metrics
        public int TotalRents { get; set; }
        public int ActiveRents { get; set; }
        public int PendingRents { get; set; }
        public int PaidRents { get; set; }
        public int CancelledRents { get; set; }
        public int RejectedRents { get; set; }
        public int AcceptedRents { get; set; }
        public int DailyRentals { get; set; }
        public int MonthlyRentals { get; set; }
        public double AverageRentalDuration { get; set; } // in days
        public double OccupancyRate { get; set; } // percentage

        // Property Metrics
        public int TotalProperties { get; set; }
        public int ActiveProperties { get; set; }
        public int InactiveProperties { get; set; }
        public List<PropertyCountByType> PropertiesByType { get; set; } = new List<PropertyCountByType>();
        public List<PropertyCountByCity> PropertiesByCity { get; set; } = new List<PropertyCountByCity>();
        public List<AveragePriceByType> AveragePriceByPropertyType { get; set; } = new List<AveragePriceByType>();

        // User Metrics
        public int TotalUsers { get; set; }
        public int ActiveUsers { get; set; }
        public int TotalLandlords { get; set; }
        public int TotalTenants { get; set; }
        public int TotalAdmins { get; set; }
        public List<MonthlyUserGrowth> MonthlyUserGrowth { get; set; } = new List<MonthlyUserGrowth>();

        // Review Metrics
        public int TotalReviews { get; set; }
        public double AverageRating { get; set; }
        public int Rating5Count { get; set; }
        public int Rating4Count { get; set; }
        public int Rating3Count { get; set; }
        public int Rating2Count { get; set; }
        public int Rating1Count { get; set; }

        // Growth Metrics
        public List<MonthlyPropertyGrowth> MonthlyPropertyGrowth { get; set; } = new List<MonthlyPropertyGrowth>();
        public List<MonthlyRentGrowth> MonthlyRentGrowth { get; set; } = new List<MonthlyRentGrowth>();
    }

    public class RevenueByPropertyType
    {
        public string PropertyTypeName { get; set; } = string.Empty;
        public decimal Revenue { get; set; }
        public int RentCount { get; set; }
    }

    public class RevenueByCity
    {
        public string CityName { get; set; } = string.Empty;
        public decimal Revenue { get; set; }
        public int RentCount { get; set; }
    }

    public class MonthlyRevenueData
    {
        public string Month { get; set; } = string.Empty; // Format: "YYYY-MM"
        public decimal Revenue { get; set; }
        public int RentCount { get; set; }
    }

    public class PropertyCountByType
    {
        public string PropertyTypeName { get; set; } = string.Empty;
        public int Count { get; set; }
        public int ActiveCount { get; set; }
    }

    public class PropertyCountByCity
    {
        public string CityName { get; set; } = string.Empty;
        public int Count { get; set; }
        public int ActiveCount { get; set; }
    }

    public class AveragePriceByType
    {
        public string PropertyTypeName { get; set; } = string.Empty;
        public decimal AveragePricePerMonth { get; set; }
        public decimal? AveragePricePerDay { get; set; }
    }

    public class MonthlyUserGrowth
    {
        public string Month { get; set; } = string.Empty;
        public int NewUsers { get; set; }
        public int TotalUsers { get; set; }
    }

    public class MonthlyPropertyGrowth
    {
        public string Month { get; set; } = string.Empty;
        public int NewProperties { get; set; }
        public int TotalProperties { get; set; }
    }

    public class MonthlyRentGrowth
    {
        public string Month { get; set; } = string.Empty;
        public int NewRents { get; set; }
        public int TotalRents { get; set; }
    }
}
