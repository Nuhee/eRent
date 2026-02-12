using Microsoft.EntityFrameworkCore;

namespace eRent.Services.Database
{
    public class eRentDbContext : DbContext
    {
        public eRentDbContext(DbContextOptions<eRentDbContext> options) : base(options)
        {
        }

        public DbSet<Chat> Chats { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<Gender> Genders { get; set; }
        public DbSet<Country> Countries { get; set; }
        public DbSet<City> Cities { get; set; }
        public DbSet<PropertyType> PropertyTypes { get; set; }
        public DbSet<Amenity> Amenities { get; set; }
        public DbSet<Property> Properties { get; set; }
        public DbSet<PropertyAmenity> PropertyAmenities { get; set; }
        public DbSet<PropertyImage> PropertyImages { get; set; }
        public DbSet<Rent> Rents { get; set; }
        public DbSet<RentStatus> RentStatuses { get; set; }
        public DbSet<ReviewRent> ReviewRents { get; set; }
        public DbSet<Payment> Payments { get; set; }
    

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure User entity
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Username)
                .IsUnique();
               

            // Configure Role entity
            modelBuilder.Entity<Role>()
                .HasIndex(r => r.Name)
                .IsUnique();

            // Configure UserRole join entity
            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.User)
                .WithMany(u => u.UserRoles)
                .HasForeignKey(ur => ur.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<UserRole>()
                .HasOne(ur => ur.Role)
                .WithMany(r => r.UserRoles)
                .HasForeignKey(ur => ur.RoleId)
                .OnDelete(DeleteBehavior.Cascade);

            // Create a unique constraint on UserId and RoleId
            modelBuilder.Entity<UserRole>()
                .HasIndex(ur => new { ur.UserId, ur.RoleId })
                .IsUnique();

         

            // Configure Gender entity
            modelBuilder.Entity<Gender>()
                .HasIndex(g => g.Name)
                .IsUnique();

            // Configure PropertyType entity
            modelBuilder.Entity<PropertyType>()
                .HasIndex(pt => pt.Name)
                .IsUnique();

            // Configure Amenity entity
            modelBuilder.Entity<Amenity>()
                .HasIndex(a => a.Name)
                .IsUnique();

            // Configure Country entity
            modelBuilder.Entity<Country>()
                .HasIndex(c => c.Name)
                .IsUnique();

            // Configure City entity
            modelBuilder.Entity<City>()
                .HasIndex(c => c.Name)
                .IsUnique();

            // Configure City-Country relationship
            modelBuilder.Entity<City>()
                .HasOne(c => c.Country)
                .WithMany(co => co.Cities)
                .HasForeignKey(c => c.CountryId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<User>()
                .HasOne(u => u.Gender)
                .WithMany()
                .HasForeignKey(u => u.GenderId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<User>()
                .HasOne(u => u.City)
                .WithMany()
                .HasForeignKey(u => u.CityId)
                .OnDelete(DeleteBehavior.NoAction);

            // Configure Property entity relationships
            modelBuilder.Entity<Property>()
                .HasOne(p => p.PropertyType)
                .WithMany()
                .HasForeignKey(p => p.PropertyTypeId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Property>()
                .HasOne(p => p.City)
                .WithMany()
                .HasForeignKey(p => p.CityId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Property>()
                .HasOne(p => p.Landlord)
                .WithMany()
                .HasForeignKey(p => p.LandlordId)
                .OnDelete(DeleteBehavior.NoAction);

            // Configure PropertyAmenity join entity (many-to-many)
            modelBuilder.Entity<PropertyAmenity>()
                .HasOne(pa => pa.Property)
                .WithMany(p => p.PropertyAmenities)
                .HasForeignKey(pa => pa.PropertyId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<PropertyAmenity>()
                .HasOne(pa => pa.Amenity)
                .WithMany()
                .HasForeignKey(pa => pa.AmenityId)
                .OnDelete(DeleteBehavior.Cascade);

            // Create a unique constraint on PropertyId and AmenityId
            modelBuilder.Entity<PropertyAmenity>()
                .HasIndex(pa => new { pa.PropertyId, pa.AmenityId })
                .IsUnique();

            // Configure PropertyImage entity relationship
            modelBuilder.Entity<PropertyImage>()
                .HasOne(pi => pi.Property)
                .WithMany(p => p.PropertyImages)
                .HasForeignKey(pi => pi.PropertyId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure Rent entity relationships
            modelBuilder.Entity<Rent>()
                .HasOne(r => r.Property)
                .WithMany(p => p.Rents)
                .HasForeignKey(r => r.PropertyId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Rent>()
                .HasOne(r => r.User)
                .WithMany(u => u.Rents)
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.NoAction);

            // Configure RentStatus entity
            modelBuilder.Entity<RentStatus>()
                .HasIndex(rs => rs.Name)
                .IsUnique();

            // Configure Rent-RentStatus relationship
            modelBuilder.Entity<Rent>()
                .HasOne(r => r.RentStatus)
                .WithMany(rs => rs.Rents)
                .HasForeignKey(r => r.RentStatusId)
                .OnDelete(DeleteBehavior.NoAction);

            // Configure ReviewRent entity relationships
            modelBuilder.Entity<ReviewRent>()
                .HasOne(rr => rr.Rent)
                .WithMany(r => r.ReviewRents)
                .HasForeignKey(rr => rr.RentId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<ReviewRent>()
                .HasOne(rr => rr.User)
                .WithMany(u => u.ReviewRents)
                .HasForeignKey(rr => rr.UserId)
                .OnDelete(DeleteBehavior.NoAction);

            // Create a unique constraint on RentId and UserId (one review per user per rent)
            modelBuilder.Entity<ReviewRent>()
                .HasIndex(rr => new { rr.RentId, rr.UserId })
                .IsUnique();

            // Configure Chat entity relationships
            modelBuilder.Entity<Chat>()
                .HasOne(c => c.Sender)
                .WithMany()
                .HasForeignKey(c => c.SenderId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Chat>()
                .HasOne(c => c.Receiver)
                .WithMany()
                .HasForeignKey(c => c.ReceiverId)
                .OnDelete(DeleteBehavior.NoAction);

            // Configure Payment entity relationships
            modelBuilder.Entity<Payment>()
                .HasOne(p => p.Rent)
                .WithMany()
                .HasForeignKey(p => p.RentId)
                .OnDelete(DeleteBehavior.NoAction);

            // Seed initial data
            modelBuilder.SeedData();
        }
    }
}
