using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;

namespace eRent.Services.Interfaces
{
    public interface IPropertyAmenityService : ICRUDService<PropertyAmenityResponse, PropertyAmenitySearchObject, PropertyAmenityUpsertRequest, PropertyAmenityUpsertRequest>
    {
    }
}
