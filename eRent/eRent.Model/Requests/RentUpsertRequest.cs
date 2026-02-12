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
        public bool IsDailyRental { get; set; } = false;

        public bool IsActive { get; set; } = true;
    }
}
