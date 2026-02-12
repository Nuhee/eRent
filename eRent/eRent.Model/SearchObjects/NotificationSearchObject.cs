using System;

namespace eRent.Model.SearchObjects
{
    public class NotificationSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? Type { get; set; }
        public bool? IsRead { get; set; }
        public string? ReferenceType { get; set; }
    }
}
