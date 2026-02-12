using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using System.Threading.Tasks;

namespace eRent.Services.Interfaces
{
    public interface INotificationService : IService<NotificationResponse, NotificationSearchObject>
    {
        Task<NotificationResponse> CreateNotificationAsync(int userId, string title, string message, int type, int? referenceId = null, string? referenceType = null);
        Task<bool> MarkAsReadAsync(int id);
        Task<int> MarkAllAsReadAsync(int userId);
        Task<int> GetUnreadCountAsync(int userId);
    }
}
