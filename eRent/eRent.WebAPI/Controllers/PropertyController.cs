using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using eRent.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eRent.WebAPI.Controllers
{
    public class PropertyController : BaseCRUDController<PropertyResponse, PropertySearchObject, PropertyUpsertRequest, PropertyUpsertRequest>
    {
        public PropertyController(IPropertyService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<PropertyResponse>> Get([FromQuery] PropertySearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<PropertyResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }

        [HttpGet("recommended/{userId}")]
        [AllowAnonymous]
        public async Task<ActionResult<List<PropertyResponse>>> GetRecommendedProperties(int userId, [FromQuery] int count = 5)
        {
            var properties = await ((IPropertyService)_service).GetRecommendedPropertiesAsync(userId, count);
            return Ok(properties);
        }
    }
}
