using System.Collections.Generic;

namespace eRent.Model.SearchObjects
{
    public class PropertySearchObject : BaseSearchObject
    {
        public string? Title { get; set; }
        public int? PropertyTypeId { get; set; }
        public int? CityId { get; set; }
        public int? CountryId { get; set; }
        public int? LandlordId { get; set; }
        public decimal? MinPricePerMonth { get; set; }
        public decimal? MaxPricePerMonth { get; set; }
        public decimal? MinPricePerDay { get; set; }
        public decimal? MaxPricePerDay { get; set; }
        public bool? AllowDailyRental { get; set; }
        public int? MinBedrooms { get; set; }
        public int? MaxBedrooms { get; set; }
        public List<int>? AmenityIds { get; set; }
        public bool? IsActive { get; set; }
    }
}
