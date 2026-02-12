using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using eRent.Services.Database;
using eRent.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Stripe;
using System;
using System.Collections.Generic;
using System.Linq;
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

        public async Task<PagedResult<PaymentResponse>> GetAsync(PaymentSearchObject search)
        {
            var query = _context.Payments
                .Include(p => p.Rent)
                    .ThenInclude(r => r!.Property)
                .Include(p => p.Rent)
                    .ThenInclude(r => r!.User)
                .AsQueryable();

            // Filter by UserId (through the Rent -> User relationship)
            if (search.UserId.HasValue)
            {
                query = query.Where(p => p.Rent != null && p.Rent.UserId == search.UserId.Value);
            }

            if (search.RentId.HasValue)
            {
                query = query.Where(p => p.RentId == search.RentId.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.Status))
            {
                query = query.Where(p => p.Status == search.Status);
            }

            if (search.DateFrom.HasValue)
            {
                query = query.Where(p => p.CreatedAt >= search.DateFrom.Value);
            }

            if (search.DateTo.HasValue)
            {
                query = query.Where(p => p.CreatedAt <= search.DateTo.Value);
            }

            if (search.MinAmount.HasValue)
            {
                query = query.Where(p => p.Amount >= search.MinAmount.Value);
            }

            if (search.MaxAmount.HasValue)
            {
                query = query.Where(p => p.Amount <= search.MaxAmount.Value);
            }

            // Full text search on customer name or property title
            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                var fts = search.FTS.ToLower();
                query = query.Where(p =>
                    (p.CustomerName != null && p.CustomerName.ToLower().Contains(fts)) ||
                    (p.Rent != null && p.Rent.Property.Title.ToLower().Contains(fts)));
            }

            // Default order by newest first
            query = query.OrderByDescending(p => p.CreatedAt);

            var result = new PagedResult<PaymentResponse>();

            if (search.IncludeTotalCount)
            {
                result.TotalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll && search.Page.HasValue && search.PageSize.HasValue)
            {
                query = query.Skip(search.Page.Value * search.PageSize.Value)
                             .Take(search.PageSize.Value);
            }

            var payments = await query.ToListAsync();
            result.Items = payments.Select(MapToResponse).ToList();

            return result;
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
                // Enriched fields
                PropertyTitle = entity.Rent?.Property?.Title ?? "N/A",
                UserId = entity.Rent?.UserId,
                UserName = entity.Rent?.User != null
                    ? $"{entity.Rent.User.FirstName} {entity.Rent.User.LastName}"
                    : entity.CustomerName ?? "N/A",
            };
        }
    }
}
