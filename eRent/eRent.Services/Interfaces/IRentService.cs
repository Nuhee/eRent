using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;

namespace eRent.Services.Interfaces
{
    public interface IRentService : ICRUDService<RentResponse, RentSearchObject, RentUpsertRequest, RentUpsertRequest>
    {
    }
}
