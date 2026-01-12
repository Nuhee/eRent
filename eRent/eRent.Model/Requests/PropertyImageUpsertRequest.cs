using System.ComponentModel.DataAnnotations;

namespace eRent.Model.Requests
{
    public class PropertyImageUpsertRequest
    {
        [Required]
        public int PropertyId { get; set; }

        public byte[]? ImageData { get; set; }

        public int? DisplayOrder { get; set; }

        public bool IsCover { get; set; } = false;

        public bool IsActive { get; set; } = true;
    }
}
