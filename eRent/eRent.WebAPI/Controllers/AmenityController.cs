using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using eRent.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eRent.WebAPI.Controllers
{
    public class AmenityController : BaseCRUDController<AmenityResponse, AmenitySearchObject, AmenityUpsertRequest, AmenityUpsertRequest>
    {
        public AmenityController(IAmenityService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<AmenityResponse>> Get([FromQuery] AmenitySearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<AmenityResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
}
