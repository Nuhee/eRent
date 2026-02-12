using System;

namespace eRent.Model.SearchObjects
{
    public class RentSearchObject : BaseSearchObject
    {
        public int? PropertyId { get; set; }
        public string? PropertyTitle { get; set; }
        public int? UserId { get; set; }
        public int? LandlordId { get; set; } // Filter by landlord's properties
        public bool? IsDailyRental { get; set; }
        public int? RentStatusId { get; set; }
        public DateTime? StartDateFrom { get; set; }
        public DateTime? StartDateTo { get; set; }
        public DateTime? EndDateFrom { get; set; }
        public DateTime? EndDateTo { get; set; }
        public bool? IsActive { get; set; }
    }
}
