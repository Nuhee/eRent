using System.ComponentModel.DataAnnotations;

namespace eRent.Model.Requests
{
    public class ReviewRentUpsertRequest
    {
        [Required]
        public int RentId { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required]
        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5")]
        public int Rating { get; set; }

        [MaxLength(1000)]
        public string? Comment { get; set; }

        public bool IsActive { get; set; } = true;
    }
}
