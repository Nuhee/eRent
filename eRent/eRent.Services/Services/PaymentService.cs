using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Services.Database;
using eRent.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Stripe;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace eRent.Services.Services
{
    public class PaymentService : IPaymentService
    {
        private readonly eRentDbContext _context;
        private readonly string _stripeSecretKey;

        public PaymentService(eRentDbContext context, IConfiguration configuration)
        {
            _context = context;
            _stripeSecretKey = configuration["STRIPE:SECRET_KEY"]
                ?? configuration["STRIPE__SECRET_KEY"]
                ?? Environment.GetEnvironmentVariable("STRIPE__SECRET_KEY")
                ?? throw new InvalidOperationException("STRIPE__SECRET_KEY configuration is missing. Please set it in .env file or environment variables.");
        }

        public async Task<PaymentIntentResponse> CreatePaymentIntentAsync(CreatePaymentIntentRequest request)
        {
            StripeConfiguration.ApiKey = _stripeSecretKey;

            // 1. Create Stripe customer
            var customerService = new CustomerService();
            var customer = await customerService.CreateAsync(new CustomerCreateOptions
            {
                Name = request.CustomerName,
                Email = request.CustomerEmail ?? "",
                Metadata = new Dictionary<string, string>
                {
                    { "address", request.BillingAddress ?? "" },
                    { "city", request.BillingCity ?? "" },
                    { "state", request.BillingState ?? "" },
                    { "country", request.BillingCountry ?? "" },
                }
            });

            // 2. Create ephemeral key for the customer
            var ephemeralKeyService = new EphemeralKeyService();
            var ephemeralKey = await ephemeralKeyService.CreateAsync(new EphemeralKeyCreateOptions
            {
                Customer = customer.Id,
            });

            // 3. Create payment intent
            var amountInCents = (long)(request.Amount * 100);
            var paymentIntentService = new PaymentIntentService();
            var paymentIntent = await paymentIntentService.CreateAsync(new PaymentIntentCreateOptions
            {
                Amount = amountInCents,
                Currency = request.Currency.ToLower(),
                Customer = customer.Id,
                AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
                {
                    Enabled = true,
                },
                Description = "eRent Property Rental Payment",
                Metadata = new Dictionary<string, string>
                {
                    { "customer_name", request.CustomerName },
                    { "billing_address", request.BillingAddress ?? "" },
                    { "billing_city", request.BillingCity ?? "" },
                    { "billing_state", request.BillingState ?? "" },
                    { "billing_country", request.BillingCountry ?? "" },
                }
            });

            // 4. Save payment record to database
            var payment = new Database.Payment
            {
                StripePaymentIntentId = paymentIntent.Id,
                StripeCustomerId = customer.Id,
                Amount = request.Amount,
                Currency = request.Currency,
                Status = "pending",
                PaymentMethod = "card",
                CustomerName = request.CustomerName,
                CustomerEmail = request.CustomerEmail,
                BillingAddress = request.BillingAddress,
                BillingCity = request.BillingCity,
                BillingState = request.BillingState,
                BillingCountry = request.BillingCountry,
                BillingZipCode = request.BillingZipCode,
                CreatedAt = DateTime.UtcNow,
            };

            _context.Payments.Add(payment);
            await _context.SaveChangesAsync();

            return new PaymentIntentResponse
            {
                PaymentId = payment.Id,
                ClientSecret = paymentIntent.ClientSecret,
                EphemeralKey = ephemeralKey.Secret,
                CustomerId = customer.Id,
            };
        }

        public async Task<PaymentResponse> ConfirmPaymentAsync(int paymentId, ConfirmPaymentRequest request)
        {
            var payment = await _context.Payments.FindAsync(paymentId);
            if (payment == null)
            {
                throw new InvalidOperationException($"Payment with ID {paymentId} not found.");
            }

            // Verify the rent exists
            var rent = await _context.Rents.FindAsync(request.RentId);
            if (rent == null)
            {
                throw new InvalidOperationException($"Rent with ID {request.RentId} not found.");
            }

            payment.RentId = request.RentId;
            payment.Status = "succeeded";
            payment.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return MapToResponse(payment);
        }

        public async Task<PaymentResponse?> GetByIdAsync(int id)
        {
            var payment = await _context.Payments
                .Include(p => p.Rent)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (payment == null)
                return null;

            return MapToResponse(payment);
        }

        private static PaymentResponse MapToResponse(Database.Payment entity)
        {
            return new PaymentResponse
            {
                Id = entity.Id,
                RentId = entity.RentId,
                StripePaymentIntentId = entity.StripePaymentIntentId,
                StripeCustomerId = entity.StripeCustomerId,
                Amount = entity.Amount,
                Currency = entity.Currency,
                Status = entity.Status,
                PaymentMethod = entity.PaymentMethod,
                CustomerName = entity.CustomerName,
                CustomerEmail = entity.CustomerEmail,
                BillingAddress = entity.BillingAddress,
                BillingCity = entity.BillingCity,
                BillingState = entity.BillingState,
                BillingCountry = entity.BillingCountry,
                BillingZipCode = entity.BillingZipCode,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
            };
        }
    }
}
