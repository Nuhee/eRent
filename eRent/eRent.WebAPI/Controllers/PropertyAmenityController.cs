using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using eRent.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eRent.WebAPI.Controllers
{
    public class PropertyAmenityController : BaseCRUDController<PropertyAmenityResponse, PropertyAmenitySearchObject, PropertyAmenityUpsertRequest, PropertyAmenityUpsertRequest>
    {
        public PropertyAmenityController(IPropertyAmenityService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<PropertyAmenityResponse>> Get([FromQuery] PropertyAmenitySearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<PropertyAmenityResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
}
