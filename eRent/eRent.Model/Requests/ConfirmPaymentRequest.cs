using System.ComponentModel.DataAnnotations;

namespace eRent.Model.Requests
{
    public class ConfirmPaymentRequest
    {
        [Required]
        public int RentId { get; set; }
    }
}
