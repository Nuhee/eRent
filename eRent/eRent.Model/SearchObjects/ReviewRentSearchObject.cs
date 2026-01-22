namespace eRent.Model.SearchObjects
{
    public class ReviewRentSearchObject : BaseSearchObject
    {
        public int? RentId { get; set; }
        public int? PropertyId { get; set; }
        public int? UserId { get; set; }
        public string? PropertyTitle { get; set; }
        public string? UserName { get; set; }
        public int? Rating { get; set; }
        public bool? IsActive { get; set; }
    }
}
