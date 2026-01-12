using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eRent.Services.Database
{
    public class PropertyAmenity
    {
        [Key]
        public int Id { get; set; }

        // Property
        public int PropertyId { get; set; }

        [ForeignKey("PropertyId")]
        public Property Property { get; set; } = null!;

        // Amenity
        public int AmenityId { get; set; }

        [ForeignKey("AmenityId")]
        public Amenity Amenity { get; set; } = null!;

        public DateTime DateAdded { get; set; } = DateTime.Now;
    }
}
