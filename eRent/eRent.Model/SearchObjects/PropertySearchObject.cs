namespace eRent.Model.SearchObjects
{
    public class PropertySearchObject : BaseSearchObject
    {
        public string? Title { get; set; }
        public int? PropertyTypeId { get; set; }
        public int? CityId { get; set; }
        public int? LandlordId { get; set; }
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public int? MinBedrooms { get; set; }
        public int? MaxBedrooms { get; set; }
        public bool? IsActive { get; set; }
    }
}
