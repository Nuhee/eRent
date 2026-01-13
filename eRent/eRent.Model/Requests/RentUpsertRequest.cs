using System;
using System.ComponentModel.DataAnnotations;

namespace eRent.Model.Requests
{
    public class RentUpsertRequest
    {
        [Required]
        public int PropertyId { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required]
        public DateTime StartDate { get; set; }

        [Required]
        public DateTime EndDate { get; set; }

        [Required]
        public bool IsDailyRental { get; set; }

        [Required]
        [Range(0.01, double.MaxValue, ErrorMessage = "Total price must be greater than 0")]
        public decimal TotalPrice { get; set; }

        public int? RentStatusId { get; set; } // Optional - will be set to Pending (1) on create if not provided

        public bool IsActive { get; set; } = true;
    }
}
