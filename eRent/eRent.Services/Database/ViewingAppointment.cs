using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eRent.Services.Database
{
    public class ViewingAppointment
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int PropertyId { get; set; }

        [Required]
        public int TenantId { get; set; } // FK to User (the person requesting viewing)

        [Required]
        public DateTime AppointmentDate { get; set; } // Date + start time

        [Required]
        public DateTime EndTime { get; set; } // AppointmentDate + 2 hours

        /// <summary>
        /// 0 = Pending, 1 = Approved, 2 = Rejected, 3 = Cancelled, 4 = Completed
        /// </summary>
        public int Status { get; set; } = 0;

        [MaxLength(500)]
        public string? TenantNote { get; set; }

        [MaxLength(500)]
        public string? LandlordNote { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        [ForeignKey("PropertyId")]
        public Property Property { get; set; } = null!;

        [ForeignKey("TenantId")]
        public User Tenant { get; set; } = null!;
    }
}
