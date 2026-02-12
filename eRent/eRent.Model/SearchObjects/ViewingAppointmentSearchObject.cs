using System;

namespace eRent.Model.SearchObjects
{
    public class ViewingAppointmentSearchObject : BaseSearchObject
    {
        public int? PropertyId { get; set; }
        public int? TenantId { get; set; }
        public int? LandlordId { get; set; }
        public int? Status { get; set; }
        public DateTime? DateFrom { get; set; }
        public DateTime? DateTo { get; set; }
    }
}
