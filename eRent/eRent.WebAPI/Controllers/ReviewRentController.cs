using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using eRent.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eRent.WebAPI.Controllers
{
    public class ReviewRentController : BaseCRUDController<ReviewRentResponse, ReviewRentSearchObject, ReviewRentUpsertRequest, ReviewRentUpsertRequest>
    {
        public ReviewRentController(IReviewRentService service) : base(service)
        {
        }

        [AllowAnonymous]
        public override async Task<PagedResult<ReviewRentResponse>> Get([FromQuery] ReviewRentSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [AllowAnonymous]
        public override async Task<ReviewRentResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }
    }
}
