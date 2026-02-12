using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using eRent.Services.Database;
using eRent.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace eRent.Services.Services
{
    public class NotificationService : INotificationService
    {
        private readonly eRentDbContext _context;

        private static readonly string[] TypeNames =
        {
            "Rent Created",        // 0
            "Rent Accepted",       // 1
            "Rent Rejected",       // 2
            "Rent Cancelled",      // 3
            "Rent Paid",           // 4
            "Viewing Created",     // 5
            "Viewing Approved",    // 6
            "Viewing Rejected",    // 7
            "Viewing Cancelled"    // 8
        };

        public NotificationService(eRentDbContext context)
        {
            _context = context;
        }

        public async Task<NotificationResponse> CreateNotificationAsync(
            int userId, string title, string message, int type,
            int? referenceId = null, string? referenceType = null)
        {
            var entity = new Notification
            {
                UserId = userId,
                Title = title,
                Message = message,
                Type = type,
                ReferenceId = referenceId,
                ReferenceType = referenceType,
                IsRead = false,
                CreatedAt = DateTime.Now
            };

            _context.Notifications.Add(entity);
            await _context.SaveChangesAsync();

            return MapToResponse(entity);
        }

        public async Task<PagedResult<NotificationResponse>> GetAsync(NotificationSearchObject search)
        {
            var query = _context.Notifications.AsQueryable();

            if (search.UserId.HasValue)
            {
                query = query.Where(n => n.UserId == search.UserId.Value);
            }

            if (search.Type.HasValue)
            {
                query = query.Where(n => n.Type == search.Type.Value);
            }

            if (search.IsRead.HasValue)
            {
                query = query.Where(n => n.IsRead == search.IsRead.Value);
            }

            if (!string.IsNullOrWhiteSpace(search.ReferenceType))
            {
                query = query.Where(n => n.ReferenceType == search.ReferenceType);
            }

            if (!string.IsNullOrWhiteSpace(search.FTS))
            {
                var fts = search.FTS.ToLower();
                query = query.Where(n =>
                    n.Title.ToLower().Contains(fts) ||
                    n.Message.ToLower().Contains(fts));
            }

            // Newest first
            query = query.OrderByDescending(n => n.CreatedAt);

            var result = new PagedResult<NotificationResponse>();

            if (search.IncludeTotalCount)
            {
                result.TotalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll && search.Page.HasValue && search.PageSize.HasValue)
            {
                query = query.Skip(search.Page.Value * search.PageSize.Value)
                             .Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();
            result.Items = list.Select(MapToResponse).ToList();

            return result;
        }

        public async Task<NotificationResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Notifications.FirstOrDefaultAsync(n => n.Id == id);
            if (entity == null) return null;
            return MapToResponse(entity);
        }

        public async Task<bool> MarkAsReadAsync(int id)
        {
            var entity = await _context.Notifications.FindAsync(id);
            if (entity == null) return false;

            entity.IsRead = true;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<int> MarkAllAsReadAsync(int userId)
        {
            var unread = await _context.Notifications
                .Where(n => n.UserId == userId && !n.IsRead)
                .ToListAsync();

            foreach (var n in unread)
            {
                n.IsRead = true;
            }

            await _context.SaveChangesAsync();
            return unread.Count;
        }

        public async Task<int> GetUnreadCountAsync(int userId)
        {
            return await _context.Notifications
                .CountAsync(n => n.UserId == userId && !n.IsRead);
        }

        private static NotificationResponse MapToResponse(Notification entity)
        {
            return new NotificationResponse
            {
                Id = entity.Id,
                UserId = entity.UserId,
                Title = entity.Title,
                Message = entity.Message,
                Type = entity.Type,
                TypeName = entity.Type >= 0 && entity.Type < TypeNames.Length
                    ? TypeNames[entity.Type]
                    : "Unknown",
                ReferenceId = entity.ReferenceId,
                ReferenceType = entity.ReferenceType,
                IsRead = entity.IsRead,
                CreatedAt = entity.CreatedAt
            };
        }
    }
}
