using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using eRent.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eRent.WebAPI.Controllers
{
    /// <summary>
    /// Manages user notifications for rent and viewing appointment updates.
    /// </summary>
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class NotificationController : ControllerBase
    {
        private readonly INotificationService _service;

        public NotificationController(INotificationService service)
        {
            _service = service;
        }

        /// <summary>
        /// Gets a paginated list of notifications with optional filtering.
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<PagedResult<NotificationResponse>>> Get([FromQuery] NotificationSearchObject search)
        {
            var result = await _service.GetAsync(search);
            return Ok(result);
        }

        /// <summary>
        /// Gets a notification by ID.
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<NotificationResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null) return NotFound();
            return Ok(result);
        }

        /// <summary>
        /// Gets the count of unread notifications for a user.
        /// </summary>
        [HttpGet("unread-count/{userId}")]
        public async Task<ActionResult<UnreadCountResponse>> GetUnreadCount(int userId)
        {
            var count = await _service.GetUnreadCountAsync(userId);
            return Ok(new UnreadCountResponse { Count = count });
        }

        /// <summary>
        /// Marks a single notification as read.
        /// </summary>
        [HttpPost("{id}/mark-read")]
        public async Task<ActionResult> MarkAsRead(int id)
        {
            var result = await _service.MarkAsReadAsync(id);
            if (!result) return NotFound();
            return Ok(new { success = true });
        }

        /// <summary>
        /// Marks all notifications as read for a user.
        /// </summary>
        [HttpPost("mark-all-read/{userId}")]
        public async Task<ActionResult> MarkAllAsRead(int userId)
        {
            var count = await _service.MarkAllAsReadAsync(userId);
            return Ok(new { success = true, markedCount = count });
        }
    }
}
