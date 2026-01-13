using System;

namespace eRent.Subscriber.Models
{
    public class RentNotificationDto
    {
        public int RentId { get; set; }
        public string NotificationType { get; set; } = null!; // "Pending", "Cancelled", "Accepted", "Rejected", "Paid"
        
        // User (tenant) information
        public string UserEmail { get; set; } = null!;
        public string UserFullName { get; set; } = null!;
        
        // Landlord information
        public string LandlordEmail { get; set; } = null!;
        public string LandlordFullName { get; set; } = null!;
        
        // Property information
        public string PropertyTitle { get; set; } = null!;
        public string PropertyAddress { get; set; } = null!;
        public string CityName { get; set; } = null!;
        public string CountryName { get; set; } = null!;
        
        // Rent information
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool IsDailyRental { get; set; }
        public decimal TotalPrice { get; set; }
        public string RentStatusName { get; set; } = null!;
    }
}
