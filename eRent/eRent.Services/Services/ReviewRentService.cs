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
    public class ReviewRentService : BaseCRUDService<ReviewRentResponse, ReviewRentSearchObject, ReviewRent, ReviewRentUpsertRequest, ReviewRentUpsertRequest>, IReviewRentService
    {
        public ReviewRentService(eRentDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<PagedResult<ReviewRentResponse>> GetAsync(ReviewRentSearchObject search)
        {
            var query = _context.ReviewRents
                .Include(x => x.Rent)
                    .ThenInclude(r => r.Property)
                .Include(x => x.User)
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
            return new PagedResult<ReviewRentResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        protected override IQueryable<ReviewRent> ApplyFilter(IQueryable<ReviewRent> query, ReviewRentSearchObject search)
        {
            if (search.RentId.HasValue)
            {
                query = query.Where(x => x.RentId == search.RentId.Value);
            }

            if (search.PropertyId.HasValue)
            {
                query = query.Where(x => x.Rent != null && x.Rent.PropertyId == search.PropertyId.Value);
            }

            if (search.UserId.HasValue)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
            }

            if (!string.IsNullOrEmpty(search.PropertyTitle))
            {
                query = query.Where(x => x.Rent != null && 
                                        x.Rent.Property != null && 
                                        x.Rent.Property.Title.Contains(search.PropertyTitle));
            }

            if (!string.IsNullOrEmpty(search.UserName))
            {
                query = query.Where(x => x.User != null && 
                                        (x.User.FirstName.Contains(search.UserName) || 
                                         x.User.LastName.Contains(search.UserName) ||
                                         (x.User.FirstName + " " + x.User.LastName).Contains(search.UserName)));
            }

            if (search.Rating.HasValue)
            {
                query = query.Where(x => x.Rating == search.Rating.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(x => x.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected ReviewRentResponse MapToResponse(ReviewRent entity)
        {
            var response = _mapper.Map<ReviewRentResponse>(entity);
            
            if (entity.Rent != null && entity.Rent.Property != null)
            {
                response.PropertyTitle = entity.Rent.Property.Title;
            }

            if (entity.User != null)
            {
                response.UserName = $"{entity.User.FirstName} {entity.User.LastName}";
            }

            return response;
        }

        public override async Task<ReviewRentResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.ReviewRents
                .Include(x => x.Rent)
                    .ThenInclude(r => r.Property)
                .Include(x => x.User)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(ReviewRent entity, ReviewRentUpsertRequest request)
        {
            // Validate Rent exists
            var rent = await _context.Rents
                .Include(r => r.RentStatus)
                .FirstOrDefaultAsync(r => r.Id == request.RentId);

            if (rent == null)
            {
                throw new InvalidOperationException("Rent does not exist.");
            }

            // Validate that the rent is paid (only paid rents can be reviewed)
            if (rent.RentStatusId != 5) // 5 = Paid
            {
                throw new InvalidOperationException("Only paid rents can be reviewed.");
            }

            // Validate User exists
            if (!await _context.Users.AnyAsync(u => u.Id == request.UserId))
            {
                throw new InvalidOperationException("User does not exist.");
            }

            // Validate that the user is the tenant who paid for this rent
            if (rent.UserId != request.UserId)
            {
                throw new InvalidOperationException("Only the tenant who paid for the rent can review it.");
            }

            // Check if user already reviewed this rent
            if (await _context.ReviewRents.AnyAsync(rr => rr.RentId == request.RentId && rr.UserId == request.UserId && rr.IsActive))
            {
                throw new InvalidOperationException("You have already reviewed this rent.");
            }
        }

        protected override async Task BeforeUpdate(ReviewRent entity, ReviewRentUpsertRequest request)
        {
            // Validate Rent exists
            var rent = await _context.Rents
                .Include(r => r.RentStatus)
                .FirstOrDefaultAsync(r => r.Id == request.RentId);

            if (rent == null)
            {
                throw new InvalidOperationException("Rent does not exist.");
            }

            // Validate that the rent is paid (only paid rents can be reviewed)
            if (rent.RentStatusId != 5) // 5 = Paid
            {
                throw new InvalidOperationException("Only paid rents can be reviewed.");
            }

            // Validate User exists
            if (!await _context.Users.AnyAsync(u => u.Id == request.UserId))
            {
                throw new InvalidOperationException("User does not exist.");
            }

            // Validate that the user is the tenant who paid for this rent
            if (rent.UserId != request.UserId)
            {
                throw new InvalidOperationException("Only the tenant who paid for the rent can review it.");
            }

            // Check if another review exists for this rent by this user (excluding current review)
            if (await _context.ReviewRents.AnyAsync(rr => rr.Id != entity.Id && rr.RentId == request.RentId && rr.UserId == request.UserId && rr.IsActive))
            {
                throw new InvalidOperationException("You have already reviewed this rent.");
            }
        }

        protected override void MapUpdateToEntity(ReviewRent entity, ReviewRentUpsertRequest request)
        {
            base.MapUpdateToEntity(entity, request);
            entity.UpdatedAt = DateTime.Now;
        }
    }
}
