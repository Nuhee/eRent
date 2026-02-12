using System;

namespace eRent.Model.SearchObjects
{
    public class PaymentSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? RentId { get; set; }
        public string? Status { get; set; }
        public DateTime? DateFrom { get; set; }
        public DateTime? DateTo { get; set; }
        public decimal? MinAmount { get; set; }
        public decimal? MaxAmount { get; set; }
    }
}
