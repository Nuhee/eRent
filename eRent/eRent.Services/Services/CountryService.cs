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
    public class CountryService : BaseCRUDService<CountryResponse, CountrySearchObject, Country, CountryUpsertRequest, CountryUpsertRequest>, ICountryService
    {
        public CountryService(eRentDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        protected override IQueryable<Country> ApplyFilter(IQueryable<Country> query, CountrySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }

            if (!string.IsNullOrEmpty(search.Code))
            {
                query = query.Where(x => x.Code != null && x.Code.Contains(search.Code));
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(x => x.IsActive == search.IsActive.Value);
            }

            return query;
        }

        protected override async Task BeforeInsert(Country entity, CountryUpsertRequest request)
        {
            if (await _context.Countries.AnyAsync(c => c.Name == request.Name))
            {
                throw new InvalidOperationException("A country with this name already exists.");
            }
        }

        protected override async Task BeforeUpdate(Country entity, CountryUpsertRequest request)
        {
            if (await _context.Countries.AnyAsync(c => c.Name == request.Name && c.Id != entity.Id))
            {
                throw new InvalidOperationException("A country with this name already exists.");
            }
        }
    }
}
