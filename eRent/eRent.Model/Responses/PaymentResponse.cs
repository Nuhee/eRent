using System;

namespace eRent.Model.Responses
{
    public class PaymentResponse
    {
        public int Id { get; set; }
        public int? RentId { get; set; }
        public string StripePaymentIntentId { get; set; } = string.Empty;
        public string? StripeCustomerId { get; set; }
        public decimal Amount { get; set; }
        public string Currency { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string? PaymentMethod { get; set; }
        public string? CustomerName { get; set; }
        public string? CustomerEmail { get; set; }
        public string? BillingAddress { get; set; }
        public string? BillingCity { get; set; }
        public string? BillingState { get; set; }
        public string? BillingCountry { get; set; }
        public string? BillingZipCode { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }

        // Enriched fields from Rent -> Property
        public string PropertyTitle { get; set; } = string.Empty;
        public int? UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
    }
}
