using System;
using System.Collections.Generic;

namespace eRent.Model.Responses
{
    public class LandlordAnalyticsResponse
    {
        // Revenue Metrics (for landlord's properties only)
        public decimal TotalRevenue { get; set; }
        public decimal MonthlyRevenue { get; set; }
        public decimal AverageRentPrice { get; set; }
        public List<RevenueByPropertyType> RevenueByPropertyType { get; set; } = new List<RevenueByPropertyType>();
        public List<RevenueByCity> RevenueByCity { get; set; } = new List<RevenueByCity>();
        public List<MonthlyRevenueData> MonthlyRevenueTrend { get; set; } = new List<MonthlyRevenueData>();

        // Rent Metrics (for landlord's properties only)
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

        // Property Metrics (landlord's properties only)
        public int TotalProperties { get; set; }
        public int ActiveProperties { get; set; }
        public int InactiveProperties { get; set; }
        public List<PropertyCountByType> PropertiesByType { get; set; } = new List<PropertyCountByType>();
        public List<PropertyCountByCity> PropertiesByCity { get; set; } = new List<PropertyCountByCity>();
        public List<AveragePriceByType> AveragePriceByPropertyType { get; set; } = new List<AveragePriceByType>();

        // Review Metrics (for landlord's properties only)
        public int TotalReviews { get; set; }
        public double AverageRating { get; set; }
        public int Rating5Count { get; set; }
        public int Rating4Count { get; set; }
        public int Rating3Count { get; set; }
        public int Rating2Count { get; set; }
        public int Rating1Count { get; set; }

        // Growth Metrics (for landlord's properties only)
        public List<MonthlyPropertyGrowth> MonthlyPropertyGrowth { get; set; } = new List<MonthlyPropertyGrowth>();
        public List<MonthlyRentGrowth> MonthlyRentGrowth { get; set; } = new List<MonthlyRentGrowth>();
    }
}
