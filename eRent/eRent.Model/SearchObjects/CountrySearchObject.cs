namespace eRent.Model.SearchObjects
{
    public class CountrySearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public string? Code { get; set; }
        public bool? IsActive { get; set; }
    }
}
