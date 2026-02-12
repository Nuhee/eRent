using System.ComponentModel.DataAnnotations;

namespace eRent.Model.Requests
{
    public class PropertyAmenityUpsertRequest
    {
        [Required]
        public int PropertyId { get; set; }

        [Required]
        public int AmenityId { get; set; }
    }
}
