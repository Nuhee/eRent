using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace eRent.Services.Database
{
    public class User
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(50)]
        public string FirstName { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(50)]
        public string LastName { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        public byte[]? Picture { get; set; }

        [Required]
        [MaxLength(100)]
        public string Username { get; set; } = string.Empty;
        
        public string PasswordHash { get; set; } = string.Empty;
        
        public string PasswordSalt { get; set; } = string.Empty;
        
        public bool IsActive { get; set; } = true;
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        
        public DateTime? LastLoginAt { get; set; }
        
        [Phone]
        [MaxLength(20)]
        public string? PhoneNumber { get; set; }
        
        // Foreign keys for Gender and City
        public int GenderId { get; set; }
        public int CityId { get; set; }
        
        // Navigation properties
        public Gender Gender { get; set; } = null!;
        public City City { get; set; } = null!;
        
        // Navigation property for the many-to-many relationship with Role
        public ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();

        // Navigation property for Rents (as tenant)
        public ICollection<Rent> Rents { get; set; } = new List<Rent>();

        // Navigation property for ReviewRents
        public ICollection<ReviewRent> ReviewRents { get; set; } = new List<ReviewRent>();
    }
} 