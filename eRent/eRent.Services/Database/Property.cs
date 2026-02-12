using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace eRent.Services.Database
{
    public class Property
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        [MaxLength(2000)]
        public string? Description { get; set; }

        [Required]
        public decimal PricePerMonth { get; set; } // Monthly rental price

        public decimal? PricePerDay { get; set; } // Daily rental price (optional, only if AllowDailyRental is true)

        public bool AllowDailyRental { get; set; } = false; // Whether landlord allows daily rentals

        [Required]
        public int Bedrooms { get; set; }

        [Required]
        public int Bathrooms { get; set; }

        [Required]
        public decimal Area { get; set; } // in square meters

        [Required]
        public int PropertyTypeId { get; set; }

        [Required]
        public int CityId { get; set; }

        [Required]
        public int LandlordId { get; set; } // FK to User (landlord)

        [MaxLength(200)]
        public string? Address { get; set; }

        [Required]
        public decimal Latitude { get; set; }

        [Required]
        public decimal Longitude { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime? UpdatedAt { get; set; }

        // Navigation properties
        public PropertyType PropertyType { get; set; } = null!;
        public City City { get; set; } = null!;
        public User Landlord { get; set; } = null!;

        // Navigation property for many-to-many relationship with Amenity
        public ICollection<PropertyAmenity> PropertyAmenities { get; set; } = new List<PropertyAmenity>();

        // Navigation property for PropertyImages
        public ICollection<PropertyImage> PropertyImages { get; set; } = new List<PropertyImage>();

        // Navigation property for Rents
        public ICollection<Rent> Rents { get; set; } = new List<Rent>();
    }
}
