using eRent.Model.Responses;
using System.Threading.Tasks;

namespace eRent.Services.Interfaces
{
    public interface ILandlordAnalyticsService
    {
        Task<LandlordAnalyticsResponse> GetLandlordAnalyticsAsync(int landlordId);
    }
}
