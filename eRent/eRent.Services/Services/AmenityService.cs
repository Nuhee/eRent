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
    public class AmenityService : BaseCRUDService<AmenityResponse, AmenitySearchObject, Amenity, AmenityUpsertRequest, AmenityUpsertRequest>, IAmenityService
    {
        public AmenityService(eRentDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Amenity> ApplyFilter(IQueryable<Amenity> query, AmenitySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(x => x.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(Amenity entity, AmenityUpsertRequest request)
        {
            if (await _context.Amenities.AnyAsync(a => a.Name == request.Name))
            {
                throw new InvalidOperationException("An amenity with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(Amenity entity, AmenityUpsertRequest request)
        {
            if (await _context.Amenities.AnyAsync(a => a.Name == request.Name && a.Id != entity.Id))
            {
                throw new InvalidOperationException("An amenity with this name already exists.");
            }
        }
    }
}
