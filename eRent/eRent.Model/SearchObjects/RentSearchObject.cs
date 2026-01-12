using System;

namespace eRent.Model.SearchObjects
{
    public class RentSearchObject : BaseSearchObject
    {
        public int? PropertyId { get; set; }
        public int? UserId { get; set; }
        public bool? IsDailyRental { get; set; }
        public string? Status { get; set; }
        public DateTime? StartDateFrom { get; set; }
        public DateTime? StartDateTo { get; set; }
        public DateTime? EndDateFrom { get; set; }
        public DateTime? EndDateTo { get; set; }
        public bool? IsActive { get; set; }
    }
}
