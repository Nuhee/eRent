using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using eRent.Model.Responses;
using eRent.Services.Database;
using eRent.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace eRent.Services.Services
{
    public class AnalyticsService : IAnalyticsService
    {
        private readonly eRentDbContext _context;

        public AnalyticsService(eRentDbContext context)
        {
            _context = context;
        }

        public async Task<AnalyticsResponse> GetAnalyticsAsync()
        {
            var response = new AnalyticsResponse();

            // Get all rents with related data
            var rents = await _context.Rents
                .Include(r => r.Property)
                    .ThenInclude(p => p.PropertyType)
                .Include(r => r.Property)
                    .ThenInclude(p => p.City)
                .Include(r => r.RentStatus)
                .ToListAsync();

            // Get all properties with related data
            var properties = await _context.Properties
                .Include(p => p.PropertyType)
                .Include(p => p.City)
                .ToListAsync();

            // Get all users with roles
            var users = await _context.Users
                .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                .ToListAsync();

            // Get all reviews
            var reviews = await _context.ReviewRents
                .Where(rr => rr.IsActive)
                .ToListAsync();

            // Get rent statuses for filtering
            var paidStatus = await _context.RentStatuses.FirstOrDefaultAsync(rs => rs.Name == "Paid");
            var pendingStatus = await _context.RentStatuses.FirstOrDefaultAsync(rs => rs.Name == "Pending");
            var cancelledStatus = await _context.RentStatuses.FirstOrDefaultAsync(rs => rs.Name == "Cancelled");
            var rejectedStatus = await _context.RentStatuses.FirstOrDefaultAsync(rs => rs.Name == "Rejected");
            var acceptedStatus = await _context.RentStatuses.FirstOrDefaultAsync(rs => rs.Name == "Accepted");

            // Revenue Metrics
            var paidRents = rents.Where(r => paidStatus != null && r.RentStatusId == paidStatus.Id).ToList();
            response.TotalRevenue = paidRents.Sum(r => r.TotalPrice);
            
            var currentMonth = DateTime.UtcNow.Month;
            var currentYear = DateTime.UtcNow.Year;
            response.MonthlyRevenue = paidRents
                .Where(r => r.CreatedAt.Month == currentMonth && r.CreatedAt.Year == currentYear)
                .Sum(r => r.TotalPrice);

            response.AverageRentPrice = paidRents.Any() 
                ? (decimal)paidRents.Average(r => (double)r.TotalPrice) 
                : 0;

            // Revenue by Property Type
            response.RevenueByPropertyType = paidRents
                .GroupBy(r => r.Property?.PropertyType?.Name ?? "Unknown")
                .Select(g => new RevenueByPropertyType
                {
                    PropertyTypeName = g.Key,
                    Revenue = g.Sum(r => r.TotalPrice),
                    RentCount = g.Count()
                })
                .OrderByDescending(x => x.Revenue)
                .ToList();

            // Revenue by City
            response.RevenueByCity = paidRents
                .GroupBy(r => r.Property?.City?.Name ?? "Unknown")
                .Select(g => new RevenueByCity
                {
                    CityName = g.Key,
                    Revenue = g.Sum(r => r.TotalPrice),
                    RentCount = g.Count()
                })
                .OrderByDescending(x => x.Revenue)
                .ToList();

            // Monthly Revenue Trend (last 12 months)
            var last12Months = Enumerable.Range(0, 12)
                .Select(i => DateTime.UtcNow.AddMonths(-i))
                .Reverse()
                .ToList();

            response.MonthlyRevenueTrend = last12Months.Select(month => new MonthlyRevenueData
            {
                Month = month.ToString("yyyy-MM"),
                Revenue = paidRents
                    .Where(r => r.CreatedAt.Year == month.Year && r.CreatedAt.Month == month.Month)
                    .Sum(r => r.TotalPrice),
                RentCount = paidRents
                    .Count(r => r.CreatedAt.Year == month.Year && r.CreatedAt.Month == month.Month)
            }).ToList();

            // Rent Metrics
            response.TotalRents = rents.Count;
            response.ActiveRents = rents.Count(r => r.IsActive);
            response.PendingRents = pendingStatus != null 
                ? rents.Count(r => r.RentStatusId == pendingStatus.Id) 
                : 0;
            response.PaidRents = paidStatus != null 
                ? rents.Count(r => r.RentStatusId == paidStatus.Id) 
                : 0;
            response.CancelledRents = cancelledStatus != null 
                ? rents.Count(r => r.RentStatusId == cancelledStatus.Id) 
                : 0;
            response.RejectedRents = rejectedStatus != null 
                ? rents.Count(r => r.RentStatusId == rejectedStatus.Id) 
                : 0;
            response.AcceptedRents = acceptedStatus != null 
                ? rents.Count(r => r.RentStatusId == acceptedStatus.Id) 
                : 0;
            response.DailyRentals = rents.Count(r => r.IsDailyRental);
            response.MonthlyRentals = rents.Count(r => !r.IsDailyRental);

            // Average Rental Duration
            var completedRents = rents.Where(r => r.EndDate <= DateTime.UtcNow).ToList();
            if (completedRents.Any())
            {
                response.AverageRentalDuration = completedRents
                    .Average(r => (r.EndDate - r.StartDate).TotalDays);
            }

            // Occupancy Rate (properties with active rents / total active properties)
            var activeProperties = properties.Where(p => p.IsActive).ToList();
            var propertiesWithActiveRents = rents
                .Where(r => r.IsActive && r.StartDate <= DateTime.UtcNow && r.EndDate >= DateTime.UtcNow)
                .Select(r => r.PropertyId)
                .Distinct()
                .Count();
            
            response.OccupancyRate = activeProperties.Any()
                ? (double)propertiesWithActiveRents / activeProperties.Count * 100
                : 0;

            // Property Metrics
            response.TotalProperties = properties.Count;
            response.ActiveProperties = properties.Count(p => p.IsActive);
            response.InactiveProperties = properties.Count(p => !p.IsActive);

            // Properties by Type
            response.PropertiesByType = properties
                .GroupBy(p => p.PropertyType?.Name ?? "Unknown")
                .Select(g => new PropertyCountByType
                {
                    PropertyTypeName = g.Key,
                    Count = g.Count(),
                    ActiveCount = g.Count(p => p.IsActive)
                })
                .OrderByDescending(x => x.Count)
                .ToList();

            // Properties by City
            response.PropertiesByCity = properties
                .GroupBy(p => p.City?.Name ?? "Unknown")
                .Select(g => new PropertyCountByCity
                {
                    CityName = g.Key,
                    Count = g.Count(),
                    ActiveCount = g.Count(p => p.IsActive)
                })
                .OrderByDescending(x => x.Count)
                .ToList();

            // Average Price by Property Type
            response.AveragePriceByPropertyType = properties
                .GroupBy(p => p.PropertyType?.Name ?? "Unknown")
                .Select(g => new AveragePriceByType
                {
                    PropertyTypeName = g.Key,
                    AveragePricePerMonth = (decimal)g.Average(p => (double)p.PricePerMonth),
                    AveragePricePerDay = g.Where(p => p.PricePerDay.HasValue).Any()
                        ? (decimal?)g.Where(p => p.PricePerDay.HasValue).Average(p => (double)p.PricePerDay!.Value)
                        : null
                })
                .ToList();

            // User Metrics
            response.TotalUsers = users.Count;
            response.ActiveUsers = users.Count(u => u.IsActive);

            // Get role IDs
            var adminRole = await _context.Roles.FirstOrDefaultAsync(r => r.Name == "Administrator");
            var landlordRole = await _context.Roles.FirstOrDefaultAsync(r => r.Name == "Landlord");
            // Tenants are regular users with RoleId = 2 (User role)

            response.TotalAdmins = adminRole != null
                ? users.Count(u => u.UserRoles.Any(ur => ur.RoleId == adminRole.Id))
                : 0;
            response.TotalLandlords = landlordRole != null
                ? users.Count(u => u.UserRoles.Any(ur => ur.RoleId == landlordRole.Id))
                : 0;
            response.TotalTenants = users.Count(u => u.UserRoles.Any(ur => ur.RoleId == 2)); // RoleId 2 = User role

            // Monthly User Growth
            response.MonthlyUserGrowth = last12Months.Select(month => new MonthlyUserGrowth
            {
                Month = month.ToString("yyyy-MM"),
                NewUsers = users.Count(u => u.CreatedAt.Year == month.Year && u.CreatedAt.Month == month.Month),
                TotalUsers = users.Count(u => u.CreatedAt <= month.AddMonths(1).AddDays(-1))
            }).ToList();

            // Review Metrics
            response.TotalReviews = reviews.Count;
            response.AverageRating = reviews.Any()
                ? reviews.Average(r => r.Rating)
                : 0;
            response.Rating5Count = reviews.Count(r => r.Rating == 5);
            response.Rating4Count = reviews.Count(r => r.Rating == 4);
            response.Rating3Count = reviews.Count(r => r.Rating == 3);
            response.Rating2Count = reviews.Count(r => r.Rating == 2);
            response.Rating1Count = reviews.Count(r => r.Rating == 1);

            // Monthly Property Growth
            response.MonthlyPropertyGrowth = last12Months.Select(month => new MonthlyPropertyGrowth
            {
                Month = month.ToString("yyyy-MM"),
                NewProperties = properties.Count(p => p.CreatedAt.Year == month.Year && p.CreatedAt.Month == month.Month),
                TotalProperties = properties.Count(p => p.CreatedAt <= month.AddMonths(1).AddDays(-1))
            }).ToList();

            // Monthly Rent Growth
            response.MonthlyRentGrowth = last12Months.Select(month => new MonthlyRentGrowth
            {
                Month = month.ToString("yyyy-MM"),
                NewRents = rents.Count(r => r.CreatedAt.Year == month.Year && r.CreatedAt.Month == month.Month),
                TotalRents = rents.Count(r => r.CreatedAt <= month.AddMonths(1).AddDays(-1))
            }).ToList();

            return response;
        }
    }
}
