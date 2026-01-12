using eRent.Model.Requests;
using eRent.Model.Responses;
using eRent.Model.SearchObjects;
using eRent.Services.Database;
using eRent.Services.Interfaces;
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

            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
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

            return query;
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
            if (!await _context.Properties.AnyAsync(p => p.Id == request.PropertyId))
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
                var property = await _context.Properties.FirstOrDefaultAsync(p => p.Id == request.PropertyId);
                if (property == null || !property.AllowDailyRental)
                {
                    throw new InvalidOperationException("Property does not allow daily rentals.");
                }
            }

            // Validate RentStatus exists
            if (!await _context.RentStatuses.AnyAsync(rs => rs.Id == request.RentStatusId))
            {
                throw new InvalidOperationException("Rent status does not exist.");
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
            if (!await _context.Properties.AnyAsync(p => p.Id == request.PropertyId))
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
                var property = await _context.Properties.FirstOrDefaultAsync(p => p.Id == request.PropertyId);
                if (property == null || !property.AllowDailyRental)
                {
                    throw new InvalidOperationException("Property does not allow daily rentals.");
                }
            }

            // Validate RentStatus exists
            if (!await _context.RentStatuses.AnyAsync(rs => rs.Id == request.RentStatusId))
            {
                throw new InvalidOperationException("Rent status does not exist.");
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

        protected override void MapUpdateToEntity(Rent entity, RentUpsertRequest request)
        {
            base.MapUpdateToEntity(entity, request);
            entity.UpdatedAt = DateTime.Now;
        }
    }
}
