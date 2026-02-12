namespace eRent.Model.SearchObjects
{
    public class PropertyImageSearchObject : BaseSearchObject
    {
        public int? PropertyId { get; set; }
        public bool? IsCover { get; set; }
        public bool? IsActive { get; set; }
    }
}
