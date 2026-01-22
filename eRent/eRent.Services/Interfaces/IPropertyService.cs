using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;

namespace eRent.Services.Interfaces
{
    public interface IPropertyService : ICRUDService<PropertyResponse, PropertySearchObject, PropertyUpsertRequest, PropertyUpsertRequest>
    {
        Task<List<PropertyResponse>> GetRecommendedPropertiesAsync(int userId, int count = 5);
    }
}
