using eRent.Model.Responses;
using eRent.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace eRent.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class LandlordAnalyticsController : ControllerBase
    {
        private readonly ILandlordAnalyticsService _service;

        public LandlordAnalyticsController(ILandlordAnalyticsService service)
        {
            _service = service;
        }

        [HttpGet("{landlordId}")]
        public async Task<ActionResult<LandlordAnalyticsResponse>> Get(int landlordId)
        {
            var analyticsData = await _service.GetLandlordAnalyticsAsync(landlordId);
            return Ok(analyticsData);
        }
    }
}
