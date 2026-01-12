using System;

namespace eRent.Services.Database
{
    public class City
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public int CountryId { get; set; }
        public bool IsActive { get; set; } = true;
        
        // Navigation property
        public Country? Country { get; set; }
    }
} 