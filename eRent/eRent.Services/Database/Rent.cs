using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eRent.Services.Database
{
    public class Rent
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int PropertyId { get; set; }

        [Required]
        public int UserId { get; set; } // FK to User (tenant)

        [Required]
        public DateTime StartDate { get; set; }

        [Required]
        public DateTime EndDate { get; set; }

        [Required]
        public bool IsDailyRental { get; set; } // true for daily, false for monthly

        [Required]
        public decimal TotalPrice { get; set; }

        [Required]
        public int RentStatusId { get; set; } = 1; // FK to RentStatus (default: Pending)

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        [ForeignKey("PropertyId")]
        public Property Property { get; set; } = null!;

        [ForeignKey("UserId")]
        public User User { get; set; } = null!;

        [ForeignKey("RentStatusId")]
        public RentStatus RentStatus { get; set; } = null!;

        // Navigation property for ReviewRents
        public ICollection<ReviewRent> ReviewRents { get; set; } = new List<ReviewRent>();
    }
}
