using System;

namespace eRent.Model.Responses
{
    public class PropertyAmenityResponse
    {
        public int Id { get; set; }
        public int PropertyId { get; set; }
        public string PropertyTitle { get; set; } = string.Empty;
        public int AmenityId { get; set; }
        public string AmenityName { get; set; } = string.Empty;
        public DateTime DateAdded { get; set; }
    }
}
