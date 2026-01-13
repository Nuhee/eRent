using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using System.Threading.Tasks;

namespace eRent.Services.Interfaces
{
    public interface IRentService : ICRUDService<RentResponse, RentSearchObject, RentUpsertRequest, RentUpsertRequest>
    {
        Task<RentResponse?> CancelAsync(int id);
        Task<RentResponse?> RejectAsync(int id);
        Task<RentResponse?> AcceptAsync(int id);
        Task<RentResponse?> PayAsync(int id);
    }
}
