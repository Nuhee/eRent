using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using eRent.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eRent.WebAPI.Controllers
{
    public class RentController : BaseCRUDController<RentResponse, RentSearchObject, RentUpsertRequest, RentUpsertRequest>
    {
        public RentController(IRentService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<RentResponse>> Get([FromQuery] RentSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<RentResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
}
