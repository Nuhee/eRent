using System.ComponentModel.DataAnnotations;

namespace eRent.Model.Requests
{
    public class CreatePaymentIntentRequest
    {
        [Required]
        public decimal Amount { get; set; }

        [Required]
        [MaxLength(10)]
        public string Currency { get; set; } = "EUR";

        [Required]
        [MaxLength(255)]
        public string CustomerName { get; set; } = string.Empty;

        [MaxLength(255)]
        public string CustomerEmail { get; set; }

        [MaxLength(500)]
        public string BillingAddress { get; set; }

        [MaxLength(100)]
        public string BillingCity { get; set; }

        [MaxLength(100)]
        public string BillingState { get; set; }

        [MaxLength(100)]
        public string BillingCountry { get; set; }

        [MaxLength(20)]
        public string BillingZipCode { get; set; }
    }
}
