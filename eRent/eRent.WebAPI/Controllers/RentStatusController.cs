using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using eRent.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eRent.WebAPI.Controllers
{
    public class RentStatusController : BaseCRUDController<RentStatusResponse, RentStatusSearchObject, RentStatusUpsertRequest, RentStatusUpsertRequest>
    {
        public RentStatusController(IRentStatusService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<RentStatusResponse>> Get([FromQuery] RentStatusSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<RentStatusResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
}
