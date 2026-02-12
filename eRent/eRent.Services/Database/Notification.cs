using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eRent.Services.Database
{
    public class Notification
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        [Required]
        [MaxLength(1000)]
        public string Message { get; set; } = string.Empty;

        /// <summary>
        /// 0=RentCreated, 1=RentAccepted, 2=RentRejected, 3=RentCancelled, 4=RentPaid,
        /// 5=ViewingCreated, 6=ViewingApproved, 7=ViewingRejected, 8=ViewingCancelled
        /// </summary>
        [Required]
        public int Type { get; set; }

        /// <summary>
        /// The ID of the related entity (RentId or ViewingAppointmentId)
        /// </summary>
        public int? ReferenceId { get; set; }

        /// <summary>
        /// "Rent" or "ViewingAppointment"
        /// </summary>
        [MaxLength(50)]
        public string? ReferenceType { get; set; }

        public bool IsRead { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        // Navigation property
        [ForeignKey("UserId")]
        public User User { get; set; } = null!;
    }
}
