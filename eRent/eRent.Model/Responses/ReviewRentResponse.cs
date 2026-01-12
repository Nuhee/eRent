using System;

namespace eRent.Model.Responses
{
    public class ReviewRentResponse
    {
        public int Id { get; set; }
        public int RentId { get; set; }
        public string PropertyTitle { get; set; } = string.Empty;
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
