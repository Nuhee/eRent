using System.Threading.Tasks;
using eRent.Model.Responses;

namespace eRent.Services.Interfaces
{
    public interface IAnalyticsService
    {
        Task<AnalyticsResponse> GetAnalyticsAsync();
    }
}
