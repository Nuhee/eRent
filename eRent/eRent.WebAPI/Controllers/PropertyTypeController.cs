using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using eRent.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eRent.WebAPI.Controllers
{
    public class PropertyTypeController : BaseCRUDController<PropertyTypeResponse, PropertyTypeSearchObject, PropertyTypeUpsertRequest, PropertyTypeUpsertRequest>
    {
        public PropertyTypeController(IPropertyTypeService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<PropertyTypeResponse>> Get([FromQuery] PropertyTypeSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<PropertyTypeResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
}
