using System.ComponentModel.DataAnnotations;

namespace eRent.Model.Requests
{
    public class RentStatusUpsertRequest
    {
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;

        [MaxLength(200)]
        public string Description { get; set; } = string.Empty;

        public bool IsActive { get; set; } = true;
    }
}
