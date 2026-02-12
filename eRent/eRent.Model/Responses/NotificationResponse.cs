using System;

namespace eRent.Model.Responses
{
    public class NotificationResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public int Type { get; set; }
        public string TypeName { get; set; } = string.Empty;
        public int? ReferenceId { get; set; }
        public string? ReferenceType { get; set; }
        public bool IsRead { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class UnreadCountResponse
    {
        public int Count { get; set; }
    }
}
