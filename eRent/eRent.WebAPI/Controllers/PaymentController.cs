using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using eRent.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eRent.WebAPI.Controllers
{
    /// <summary>
    /// Handles Stripe payment operations for property rentals.
    /// </summary>
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class PaymentController : ControllerBase
    {
        private readonly IPaymentService _service;

        public PaymentController(IPaymentService service)
        {
            _service = service;
        }

        /// <summary>
        /// Gets a list of payments with optional filtering.
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<PagedResult<PaymentResponse>>> Get([FromQuery] PaymentSearchObject search)
        {
            var result = await _service.GetAsync(search);
            return Ok(result);
        }

        /// <summary>
        /// Creates a Stripe PaymentIntent server-side and returns the client secret for the mobile app.
        /// </summary>
        [HttpPost("create-payment-intent")]
        public async Task<ActionResult<PaymentIntentResponse>> CreatePaymentIntent([FromBody] CreatePaymentIntentRequest request)
        {
            try
            {
                var result = await _service.CreatePaymentIntentAsync(request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        /// <summary>
        /// Confirms a payment after successful Stripe payment and links it to a rent.
        /// </summary>
        [HttpPut("{id}/confirm")]
        public async Task<ActionResult<PaymentResponse>> ConfirmPayment(int id, [FromBody] ConfirmPaymentRequest request)
        {
            try
            {
                var result = await _service.ConfirmPaymentAsync(id, request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        /// <summary>
        /// Gets a payment record by ID.
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<PaymentResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null)
                return NotFound();

            return Ok(result);
        }
    }
}
