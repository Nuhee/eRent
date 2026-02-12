using eRent.Model.Requests;
using eRent.Model.Responses;
using System.Threading.Tasks;

namespace eRent.Services.Interfaces
{
    public interface IPaymentService
    {
        Task<PaymentIntentResponse> CreatePaymentIntentAsync(CreatePaymentIntentRequest request);
        Task<PaymentResponse> ConfirmPaymentAsync(int paymentId, ConfirmPaymentRequest request);
        Task<PaymentResponse?> GetByIdAsync(int id);
    }
}
