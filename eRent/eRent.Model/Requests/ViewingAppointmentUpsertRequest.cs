using System;
using System.ComponentModel.DataAnnotations;

namespace eRent.Model.Requests
{
    public class ViewingAppointmentUpsertRequest
    {
        [Required]
        public int PropertyId { get; set; }

        [Required]
        public int TenantId { get; set; }

        [Required]
        public DateTime AppointmentDate { get; set; }

        [MaxLength(500)]
        public string? TenantNote { get; set; }
    }
}
