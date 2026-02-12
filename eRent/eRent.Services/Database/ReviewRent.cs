using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eRent.Services.Database
{
    public class ReviewRent
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int RentId { get; set; } // FK to Rent

        [Required]
        public int UserId { get; set; } // FK to User (the reviewer - must be the tenant who paid)

        [Required]
        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5")]
        public int Rating { get; set; } // 1-5 stars

        [MaxLength(1000)]
        public string? Comment { get; set; } // Optional review comment

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        [ForeignKey("RentId")]
        public Rent Rent { get; set; } = null!;

        [ForeignKey("UserId")]
        public User User { get; set; } = null!;
    }
}
