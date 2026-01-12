using eRent.Services.Database;
using System.Collections.Generic;
using System.Threading.Tasks;
using eRent.Model.Responses;
using eRent.Model.Requests;
using eRent.Model.SearchObjects;

namespace eRent.Services.Interfaces
{
    public interface ICRUDService<T, TSearch, TInsert, TUpdate> : IService<T, TSearch> where T : class where TSearch : BaseSearchObject where TInsert : class where TUpdate : class
    {
        Task<T> CreateAsync(TInsert request);
        Task<T?> UpdateAsync(int id, TUpdate request);
        Task<bool> DeleteAsync(int id);
    }
}