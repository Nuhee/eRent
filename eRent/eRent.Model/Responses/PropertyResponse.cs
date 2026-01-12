using System;
using System.Collections.Generic;

namespace eRent.Model.Responses
{
    public class PropertyResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public decimal PricePerMonth { get; set; }
        public decimal? PricePerDay { get; set; }
        public bool AllowDailyRental { get; set; }
        public int Bedrooms { get; set; }
        public int Bathrooms { get; set; }
        public decimal Area { get; set; }
        public int PropertyTypeId { get; set; }
        public string PropertyTypeName { get; set; } = string.Empty;
        public int CityId { get; set; }
        public string CityName { get; set; } = string.Empty;
        public int LandlordId { get; set; }
        public string LandlordName { get; set; } = string.Empty;
        public string? Address { get; set; }
        public decimal Latitude { get; set; }
        public decimal Longitude { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        public List<AmenityResponse> Amenities { get; set; } = new List<AmenityResponse>();
        public List<PropertyImageResponse> Images { get; set; } = new List<PropertyImageResponse>();
    }
}
