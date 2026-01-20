using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using eRent.Services.Database;
using eRent.Services.Interfaces;
using eRent.Subscriber.Models;
using EasyNetQ;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace eRent.Services.Services
{
    public class RentService : BaseCRUDService<RentResponse, RentSearchObject, Rent, RentUpsertRequest, RentUpsertRequest>, IRentService
    {
        public RentService(eRentDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<RentResponse> CreateAsync(RentUpsertRequest request)
        {
            var result = await base.CreateAsync(request);
            
            // Send notification after successful creation
            await SendRentNotificationAsync(result.Id, "Pending");
            
            return result;
        }

        public override async Task<PagedResult<RentResponse>> GetAsync(RentSearchObject search)
        {
            var query = _context.Rents
                .Include(x => x.Property)
                .Include(x => x.User)
                .Include(x => x.RentStatus)
                .AsQueryable();

            query = ApplyFilter(query, search);

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            var list = await query.ToListAsync();
            return new PagedResult<RentResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        protected override IQueryable<Rent> ApplyFilter(IQueryable<Rent> query, RentSearchObject search)
        {
            if (search.PropertyId.HasValue)
            {
                query = query.Where(x => x.PropertyId == search.PropertyId.Value);
            }

            if (!string.IsNullOrEmpty(search.PropertyTitle))
            {
                query = query.Where(x => x.Property != null && x.Property.Title.Contains(search.PropertyTitle));
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
            }

            // Filter by landlord's properties
            if (search.LandlordId.HasValue)
            {
                query = query.Where(x => x.Property != null && x.Property.LandlordId == search.LandlordId.Value);
            }

            if (search.IsDailyRental.HasValue)
            {
                query = query.Where(x => x.IsDailyRental == search.IsDailyRental.Value);
            }

            if (search.RentStatusId.HasValue)
            {
                query = query.Where(x => x.RentStatusId == search.RentStatusId.Value);
            }

            if (search.StartDateFrom.HasValue)
            {
                query = query.Where(x => x.StartDate >= search.StartDateFrom.Value);
            }

            if (search.StartDateTo.HasValue)
            {
                query = query.Where(x => x.StartDate <= search.StartDateTo.Value);
            }

            if (search.EndDateFrom.HasValue)
            {
                query = query.Where(x => x.EndDate >= search.EndDateFrom.Value);
            }

            if (search.EndDateTo.HasValue)
            {
                query = query.Where(x => x.EndDate <= search.EndDateTo.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(x => x.IsActive == search.IsActive.Value);
            }

            // Order by ID descending so newest rents appear first
            return query.OrderByDescending(x => x.Id);
        }

        protected RentResponse MapToResponse(Rent entity)
        {
            var response = _mapper.Map<RentResponse>(entity);
            
            if (entity.Property != null)
            {
                response.PropertyTitle = entity.Property.Title;
            }

            if (entity.User != null)
            {
                response.UserName = $"{entity.User.FirstName} {entity.User.LastName}";
            }

            if (entity.RentStatus != null)
            {
                response.RentStatusName = entity.RentStatus.Name;
            }

            return response;
        }

        public override async Task<RentResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Rents
                .Include(x => x.Property)
                .Include(x => x.User)
                .Include(x => x.RentStatus)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(Rent entity, RentUpsertRequest request)
        {
            // Validate Property exists
            var property = await _context.Properties.FirstOrDefaultAsync(p => p.Id == request.PropertyId);
            if (property == null)
            {
                throw new InvalidOperationException("Property does not exist.");
            }

            // Validate User exists
            if (!await _context.Users.AnyAsync(u => u.Id == request.UserId))
            {
                throw new InvalidOperationException("User does not exist.");
            }

            // Validate dates
            if (request.StartDate >= request.EndDate)
            {
                throw new InvalidOperationException("Start date must be before end date.");
            }

            // Validate daily rental availability
            if (request.IsDailyRental)
            {
                if (!property.AllowDailyRental)
                {
                    throw new InvalidOperationException("Property does not allow daily rentals.");
                }
                
                if (property.PricePerDay == null || property.PricePerDay <= 0)
                {
                    throw new InvalidOperationException("Property does not have a valid daily price set.");
                }
            }

            // Calculate TotalPrice based on rental type
            if (request.IsDailyRental && property.AllowDailyRental && property.PricePerDay.HasValue)
            {
                // Calculate daily rental: PricePerDay * number of days
                var days = (request.EndDate - request.StartDate).Days;
                if (days <= 0)
                {
                    throw new InvalidOperationException("Invalid date range for daily rental.");
                }
                entity.TotalPrice = property.PricePerDay.Value * days;
            }
            else
            {
                // Calculate monthly rental: PricePerMonth * number of months
                var months = CalculateMonths(request.StartDate, request.EndDate);
                if (months <= 0)
                {
                    throw new InvalidOperationException("Invalid date range for monthly rental.");
                }
                entity.TotalPrice = property.PricePerMonth * months;
            }

            // Check for overlapping rentals (only for Accepted or Paid statuses)
            var overlappingRents = await _context.Rents
                .Where(r => r.PropertyId == request.PropertyId 
                    && r.IsActive 
                    && (r.RentStatusId == 4 || r.RentStatusId == 5) // Accepted (4) or Paid (5)
                    && ((r.StartDate <= request.StartDate && r.EndDate > request.StartDate) ||
                        (r.StartDate < request.EndDate && r.EndDate >= request.EndDate) ||
                        (r.StartDate >= request.StartDate && r.EndDate <= request.EndDate)))
                .AnyAsync();

            if (overlappingRents)
            {
                throw new InvalidOperationException("Property is already rented for the selected dates.");
            }
        }

        protected override async Task BeforeUpdate(Rent entity, RentUpsertRequest request)
        {
            // Validate Property exists
            var property = await _context.Properties.FirstOrDefaultAsync(p => p.Id == request.PropertyId);
            if (property == null)
            {
                throw new InvalidOperationException("Property does not exist.");
            }

            // Validate User exists
            if (!await _context.Users.AnyAsync(u => u.Id == request.UserId))
            {
                throw new InvalidOperationException("User does not exist.");
            }

            // Validate dates
            if (request.StartDate >= request.EndDate)
            {
                throw new InvalidOperationException("Start date must be before end date.");
            }

            // Validate daily rental availability
            if (request.IsDailyRental)
            {
                if (!property.AllowDailyRental)
                {
                    throw new InvalidOperationException("Property does not allow daily rentals.");
                }
                
                if (property.PricePerDay == null || property.PricePerDay <= 0)
                {
                    throw new InvalidOperationException("Property does not have a valid daily price set.");
                }
            }

            // Recalculate TotalPrice if dates or rental type changed
            bool datesChanged = entity.StartDate != request.StartDate || entity.EndDate != request.EndDate;
            bool rentalTypeChanged = entity.IsDailyRental != request.IsDailyRental;
            
            if (datesChanged || rentalTypeChanged)
            {
                if (request.IsDailyRental && property.AllowDailyRental && property.PricePerDay.HasValue)
                {
                    // Calculate daily rental: PricePerDay * number of days
                    var days = (request.EndDate - request.StartDate).Days;
                    if (days <= 0)
                    {
                        throw new InvalidOperationException("Invalid date range for daily rental.");
                    }
                    entity.TotalPrice = property.PricePerDay.Value * days;
                }
                else
                {
                    // Calculate monthly rental: PricePerMonth * number of months
                    var months = CalculateMonths(request.StartDate, request.EndDate);
                    if (months <= 0)
                    {
                        throw new InvalidOperationException("Invalid date range for monthly rental.");
                    }
                    entity.TotalPrice = property.PricePerMonth * months;
                }
            }

            // Check for overlapping rentals (excluding current rent, only for Accepted or Paid statuses)
            var overlappingRents = await _context.Rents
                .Where(r => r.Id != entity.Id
                    && r.PropertyId == request.PropertyId 
                    && r.IsActive 
                    && (r.RentStatusId == 4 || r.RentStatusId == 5) // Accepted (4) or Paid (5)
                    && ((r.StartDate <= request.StartDate && r.EndDate > request.StartDate) ||
                        (r.StartDate < request.EndDate && r.EndDate >= request.EndDate) ||
                        (r.StartDate >= request.StartDate && r.EndDate <= request.EndDate)))
                .AnyAsync();

            if (overlappingRents)
            {
                throw new InvalidOperationException("Property is already rented for the selected dates.");
            }
        }

        protected override Rent MapInsertToEntity(Rent entity, RentUpsertRequest request)
        {
            base.MapInsertToEntity(entity, request);
            
            // Always set RentStatusId to Pending (1) on create
            entity.RentStatusId = 1; // Pending
            
            // TotalPrice will be calculated in BeforeInsert
            
            return entity;
        }
        
        private int CalculateMonths(DateTime startDate, DateTime endDate)
        {
            // Calculate the base difference in months
            int months = (endDate.Year - startDate.Year) * 12 + (endDate.Month - startDate.Month);
            
            // For rental purposes, we count calendar months
            // Examples:
            // Jan 1 to Jan 31 = 1 month (the month of January)
            // Jan 1 to Feb 1 = 1 month (the month of January, Feb 1 is start of next month)
            // Jan 1 to Mar 1 = 2 months (January and February)
            // Jan 15 to Feb 15 = 1 month (partial month counts as 1)
            
            // If same month, it's 1 month
            // If different months, months already contains the correct count
            // (e.g., Jan to Feb = 1, Jan to Mar = 2)
            
            return Math.Max(1, months); // At least 1 month
        }

        protected override void MapUpdateToEntity(Rent entity, RentUpsertRequest request)
        {
            base.MapUpdateToEntity(entity, request);
            
            // TotalPrice recalculation is handled in BeforeUpdate if dates or rental type changed
            // RentStatusId should not be updated via regular update - use custom actions instead
            
            entity.UpdatedAt = DateTime.Now;
        }

        public async Task<RentResponse?> CancelAsync(int id)
        {
            var entity = await _context.Rents
                .Include(x => x.Property)
                .Include(x => x.User)
                .Include(x => x.RentStatus)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                return null;

            // Can cancel if status is Pending (1) or Accepted (4)
            if (entity.RentStatusId != 1 && entity.RentStatusId != 4)
            {
                throw new InvalidOperationException("Rent can only be cancelled if it is in Pending or Accepted status.");
            }

            entity.RentStatusId = 2; // Cancelled
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            
            // Send notification
            await SendRentNotificationAsync(entity.Id, "Cancelled");
            
            return MapToResponse(entity);
        }

        public async Task<RentResponse?> RejectAsync(int id)
        {
            var entity = await _context.Rents
                .Include(x => x.Property)
                .Include(x => x.User)
                .Include(x => x.RentStatus)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                return null;

            // Can only reject if status is Pending (1)
            if (entity.RentStatusId != 1)
            {
                throw new InvalidOperationException("Rent can only be rejected if it is in Pending status.");
            }

            entity.RentStatusId = 3; // Rejected
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            
            // Send notification
            await SendRentNotificationAsync(entity.Id, "Rejected");
            
            return MapToResponse(entity);
        }

        public async Task<RentResponse?> AcceptAsync(int id)
        {
            var entity = await _context.Rents
                .Include(x => x.Property)
                .Include(x => x.User)
                .Include(x => x.RentStatus)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                return null;

            // Can only accept if status is Pending (1)
            if (entity.RentStatusId != 1)
            {
                throw new InvalidOperationException("Rent can only be accepted if it is in Pending status.");
            }

            // Check for overlapping rentals (only for Accepted or Paid statuses)
            var overlappingRents = await _context.Rents
                .Where(r => r.Id != entity.Id
                    && r.PropertyId == entity.PropertyId
                    && r.IsActive
                    && (r.RentStatusId == 4 || r.RentStatusId == 5) // Accepted (4) or Paid (5)
                    && ((r.StartDate <= entity.StartDate && r.EndDate > entity.StartDate) ||
                        (r.StartDate < entity.EndDate && r.EndDate >= entity.EndDate) ||
                        (r.StartDate >= entity.StartDate && r.EndDate <= entity.EndDate)))
                .AnyAsync();

            if (overlappingRents)
            {
                throw new InvalidOperationException("Cannot accept rent - property is already rented for the selected dates.");
            }

            entity.RentStatusId = 4; // Accepted
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            
            // Send notification
            await SendRentNotificationAsync(entity.Id, "Accepted");
            
            return MapToResponse(entity);
        }

        public async Task<RentResponse?> PayAsync(int id)
        {
            var entity = await _context.Rents
                .Include(x => x.Property)
                .Include(x => x.User)
                .Include(x => x.RentStatus)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                return null;

            // Can only pay if status is Accepted (4)
            if (entity.RentStatusId != 4)
            {
                throw new InvalidOperationException("Rent can only be paid if it is in Accepted status.");
            }

            entity.RentStatusId = 5; // Paid
            entity.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            
            // Send notification
            await SendRentNotificationAsync(entity.Id, "Paid");
            
            return MapToResponse(entity);
        }

        private async Task SendRentNotificationAsync(int rentId, string notificationType)
        {
            try
            {
                var rent = await _context.Rents
                    .Include(r => r.User)
                    .Include(r => r.Property)
                        .ThenInclude(p => p.Landlord)
                    .Include(r => r.Property)
                        .ThenInclude(p => p.City)
                            .ThenInclude(c => c.Country)
                    .Include(r => r.RentStatus)
                    .FirstOrDefaultAsync(r => r.Id == rentId);

                if (rent == null || rent.User == null || rent.Property == null || rent.Property.Landlord == null)
                {
                    return;
                }

                var host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
                var username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
                var password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
                var virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

                using var bus = RabbitHutch.CreateBus($"host={host};virtualHost={virtualhost};username={username};password={password}");

                var notification = new RentNotification
                {
                    Rent = new RentNotificationDto
                    {
                        RentId = rent.Id,
                        NotificationType = notificationType,
                        UserEmail = rent.User.Email,
                        UserFullName = $"{rent.User.FirstName} {rent.User.LastName}".Trim(),
                        LandlordEmail = rent.Property.Landlord.Email,
                        LandlordFullName = $"{rent.Property.Landlord.FirstName} {rent.Property.Landlord.LastName}".Trim(),
                        PropertyTitle = rent.Property.Title,
                        PropertyAddress = rent.Property.Address ?? string.Empty,
                        CityName = rent.Property.City?.Name ?? string.Empty,
                        CountryName = rent.Property.City?.Country?.Name ?? string.Empty,
                        StartDate = rent.StartDate,
                        EndDate = rent.EndDate,
                        IsDailyRental = rent.IsDailyRental,
                        TotalPrice = rent.TotalPrice,
                        RentStatusName = rent.RentStatus?.Name ?? notificationType
                    }
                };

                await bus.PubSub.PublishAsync(notification);
            }
            catch (Exception ex)
            {
                // Log error but don't throw - notification failure shouldn't break rent operations
                Console.WriteLine($"Failed to send rent notification: {ex.Message}");
            }
        }
    }
}
