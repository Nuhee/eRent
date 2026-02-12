using System.ComponentModel.DataAnnotations;

namespace eRent.Model.Requests
{
    public class CountryUpsertRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(10)]
        public string? Code { get; set; }
        
        public bool IsActive { get; set; } = true;
    }
}
