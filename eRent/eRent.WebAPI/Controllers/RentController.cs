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
        private readonly IRentService _rentService;

        public RentController(IRentService service) : base(service)
        {
            _rentService = service;
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

        [HttpPost("{id}/cancel")]
        public async Task<RentResponse?> Cancel(int id)
        {
            return await _rentService.CancelAsync(id);
        }

        [HttpPost("{id}/reject")]
        public async Task<RentResponse?> Reject(int id)
        {
            return await _rentService.RejectAsync(id);
        }

        [HttpPost("{id}/accept")]
        public async Task<RentResponse?> Accept(int id)
        {
            return await _rentService.AcceptAsync(id);
        }

        [HttpPost("{id}/pay")]
        public async Task<RentResponse?> Pay(int id)
        {
            return await _rentService.PayAsync(id);
        }
    }
}
