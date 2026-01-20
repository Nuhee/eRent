using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace eRent.Services.Interfaces
{
    public interface IChatService : ICRUDService<ChatResponse, ChatSearchObject, ChatUpsertRequest, ChatUpsertRequest>
    {
        Task<bool> MarkAsReadAsync(int chatId);
        Task<int> GetUnreadCountAsync(int userId);
        Task<bool> MarkConversationAsReadAsync(int senderId, int receiverId);
        Task<PagedResult<ChatResponse>> GetOptimizedAsync(ChatSearchObject search);
        Task<List<ConversationResponse>> GetConversationsAsync(int userId);
        Task<PagedResult<ChatResponse>> GetConversationMessagesAsync(int userId, int otherUserId, int page = 0, int pageSize = 50);
    }
} 