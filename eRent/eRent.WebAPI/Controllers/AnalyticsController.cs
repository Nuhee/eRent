using Microsoft.AspNetCore.Mvc;
using eRent.Services.Interfaces;

namespace eRent.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
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
            try
            {
                var analytics = await _analyticsService.GetAnalyticsAsync();
                return Ok(analytics);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while fetching analytics.", error = ex.Message });
            }
        }
    }
}
