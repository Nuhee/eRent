using System;

namespace eRent.Model.Responses
{
    public class ViewingAppointmentResponse
    {
        public int Id { get; set; }
        public int PropertyId { get; set; }
        public string PropertyTitle { get; set; } = string.Empty;
        public string PropertyAddress { get; set; } = string.Empty;
        public int TenantId { get; set; }
        public string TenantName { get; set; } = string.Empty;
        public int LandlordId { get; set; }
        public DateTime AppointmentDate { get; set; }
        public DateTime EndTime { get; set; }
        public int Status { get; set; }
        public string StatusName { get; set; } = string.Empty;
        public string? TenantNote { get; set; }
        public string? LandlordNote { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
