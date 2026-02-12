using System.ComponentModel.DataAnnotations;

namespace eRent.Model.Requests
{
    public class AmenityUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;
        
        public bool IsActive { get; set; } = true;
    }
}
