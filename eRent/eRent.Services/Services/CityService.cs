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
    public class CityService : BaseCRUDService<CityResponse, CitySearchObject, City, CityUpsertRequest, CityUpsertRequest>, ICityService
    {
        public CityService(eRentDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task<PagedResult<CityResponse>> GetAsync(CitySearchObject search)
        {
            var query = _context.Cities.Include(x => x.Country).AsQueryable();
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
            return new PagedResult<CityResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        protected override IQueryable<City> ApplyFilter(IQueryable<City> query, CitySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }

            if (search.CountryId.HasValue)
            {
                query = query.Where(x => x.CountryId == search.CountryId.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(x => x.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected CityResponse MapToResponse(City entity)
        {
            var response = _mapper.Map<CityResponse>(entity);
            if (entity.Country != null)
            {
                response.CountryName = entity.Country.Name;
            }
            return response;
        }

        public override async Task<CityResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Cities
                .Include(x => x.Country)
                .FirstOrDefaultAsync(x => x.Id == id);
            
            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        public override async Task<CityResponse> CreateAsync(CityUpsertRequest request)
        {
            var entity = new City();
            MapInsertToEntity(entity, request);
            _context.Cities.Add(entity);

            await BeforeInsert(entity, request);

            await _context.SaveChangesAsync();
            
            // Reload with Country relationship
            await _context.Entry(entity).Reference(x => x.Country).LoadAsync();
            return MapToResponse(entity);
        }

        public override async Task<CityResponse?> UpdateAsync(int id, CityUpsertRequest request)
        {
            var entity = await _context.Cities.FindAsync(id);
            if (entity == null)
                return null;

            await BeforeUpdate(entity, request);

            MapUpdateToEntity(entity, request);

            await _context.SaveChangesAsync();
            
            // Reload with Country relationship
            await _context.Entry(entity).Reference(x => x.Country).LoadAsync();
            return MapToResponse(entity);
        }

        protected override async Task BeforeInsert(City entity, CityUpsertRequest request)
        {
            if (await _context.Cities.AnyAsync(c => c.Name == request.Name))
            {
                throw new InvalidOperationException("A city with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(City entity, CityUpsertRequest request)
        {
            if (await _context.Cities.AnyAsync(c => c.Name == request.Name && c.Id != entity.Id))
            {
                throw new InvalidOperationException("A city with this name already exists.");
            }
        }
    }
} 