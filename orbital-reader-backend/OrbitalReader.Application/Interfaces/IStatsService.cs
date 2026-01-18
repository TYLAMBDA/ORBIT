using OrbitalReader.Application.DTOs;

namespace OrbitalReader.Application.Interfaces;

public interface IStatsService
{
    Task<UserStatsDto> GetUserStatsAsync(int userId);
    Task SyncProgressAsync(int userId, SyncDto dto);
}
