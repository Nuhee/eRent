namespace eRent.Model.SearchObjects
{
    public class ReviewRentSearchObject : BaseSearchObject
    {
        public int? RentId { get; set; }
        public int? UserId { get; set; }
        public int? MinRating { get; set; }
        public int? MaxRating { get; set; }
        public bool? IsActive { get; set; }
    }
}
