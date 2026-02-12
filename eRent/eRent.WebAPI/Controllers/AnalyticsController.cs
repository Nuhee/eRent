using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using eRent.Services.Interfaces;

namespace eRent.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class AnalyticsController : ControllerBase
    {
        private readonly IAnalyticsService _analyticsService;

        public AnalyticsController(IAnalyticsService analyticsService)
        {
            _analyticsService = analyticsService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAnalytics()
        {
            var analytics = await _analyticsService.GetAnalyticsAsync();
            return Ok(analytics);
        }
    }
}
