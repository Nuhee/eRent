using eRent.Services.Database;
using System.Collections.Generic;
using System.Threading.Tasks;
using eRent.Model.Responses;
using eRent.Model.Requests;
using eRent.Model.SearchObjects;
using eRent.Services.Services;

namespace eRent.Services.Interfaces
{
    public interface IUserService : IService<UserResponse, UserSearchObject>
    {
        Task<UserResponse?> AuthenticateAsync(UserLoginRequest request);
        Task<UserResponse> CreateAsync(UserUpsertRequest request);
        Task<UserResponse?> UpdateAsync(int id, UserUpsertRequest request);
        Task<bool> DeleteAsync(int id);
    }
}