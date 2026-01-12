using eRent.Services.Database;
using System.Collections.Generic;
using System.Threading.Tasks;
using eRent.Model.Responses;
using eRent.Model.Requests;
using eRent.Model.SearchObjects;

namespace eRent.Services.Interfaces
{
    public interface IService<T, TSearch> where T : class where TSearch : BaseSearchObject
    {
        Task<PagedResult<T>> GetAsync(TSearch search);
        Task<T?> GetByIdAsync(int id);
    }
}