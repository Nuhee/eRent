using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace eRent.Services.Database
{
    public class RentStatus
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(200)]
        public string Description { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public bool IsActive { get; set; } = true;

        // Navigation property for Rents
        public ICollection<Rent> Rents { get; set; } = new List<Rent>();
    }
}
