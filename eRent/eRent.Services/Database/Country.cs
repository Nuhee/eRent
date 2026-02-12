namespace eRent.Services.Database
{
    public class Country
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Code { get; set; }
        public bool IsActive { get; set; } = true;
        
        // Navigation property
        public ICollection<City> Cities { get; set; } = new List<City>();
    }
}
