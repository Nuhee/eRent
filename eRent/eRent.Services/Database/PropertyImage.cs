using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace eRent.Services.Database
{
    public class PropertyImage
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int PropertyId { get; set; }

        [ForeignKey("PropertyId")]
        public Property Property { get; set; } = null!;

        [Required]
        public byte[] ImageData { get; set; } = Array.Empty<byte>();

        public int? DisplayOrder { get; set; } // For ordering images (1, 2, 3, etc.)

        public bool IsCover { get; set; } = false; // Mark one image as cover for the property

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
