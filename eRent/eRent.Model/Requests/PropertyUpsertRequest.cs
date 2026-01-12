using System.ComponentModel.DataAnnotations;

namespace eRent.Model.Requests
{
    public class PropertyUpsertRequest
    {
        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        [MaxLength(2000)]
        public string? Description { get; set; }

        [Required]
        [Range(0.01, double.MaxValue, ErrorMessage = "Price must be greater than 0")]
        public decimal Price { get; set; }

        [Required]
        [Range(0, int.MaxValue, ErrorMessage = "Bedrooms must be 0 or greater")]
        public int Bedrooms { get; set; }

        [Required]
        [Range(0, int.MaxValue, ErrorMessage = "Bathrooms must be 0 or greater")]
        public int Bathrooms { get; set; }

        [Required]
        [Range(0.01, double.MaxValue, ErrorMessage = "Area must be greater than 0")]
        public decimal Area { get; set; }

        [Required]
        public int PropertyTypeId { get; set; }

        [Required]
        public int CityId { get; set; }

        [Required]
        public int LandlordId { get; set; }

        [MaxLength(200)]
        public string? Address { get; set; }

        public bool IsActive { get; set; } = true;

        // List of amenity IDs for many-to-many relationship
        public List<int> AmenityIds { get; set; } = new List<int>();
    }
}
