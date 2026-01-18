using OrbitalReader.Application.DTOs;
using OrbitalReader.Core.Entities;

namespace OrbitalReader.Application.Interfaces;

public interface IUserService
{
    Task<AuthResponseDto> RegisterAsync(RegisterDto dto);
    Task<AuthResponseDto> LoginAsync(LoginDto dto);
}
