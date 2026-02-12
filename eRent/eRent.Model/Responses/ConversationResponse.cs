using System;

namespace eRent.Model.Responses
{
    public class ConversationResponse
    {
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public byte[]? UserPicture { get; set; }
        public string LastMessage { get; set; } = string.Empty;
        public DateTime LastMessageAt { get; set; }
        public int UnreadCount { get; set; }
        public bool IsLastMessageFromMe { get; set; }
    }
}
