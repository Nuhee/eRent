using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;

namespace eRent.Services.Interfaces
{
    public interface IRentStatusService : ICRUDService<RentStatusResponse, RentStatusSearchObject, RentStatusUpsertRequest, RentStatusUpsertRequest>
    {
    }
}
