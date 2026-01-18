using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OrbitalReader.Application.DTOs;
using OrbitalReader.Application.Interfaces;
using System.Security.Claims;

namespace OrbitalReader.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class StatsController : ControllerBase
{
    private readonly IStatsService _statsService;

    public StatsController(IStatsService statsService)
    {
        _statsService = statsService;
    }

    [HttpGet]
    public async Task<ActionResult<UserStatsDto>> GetStats()
    {
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        return Ok(await _statsService.GetUserStatsAsync(userId));
    }

    [HttpPost("sync")]
    public async Task<ActionResult> SyncProgress(SyncDto dto)
    {
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        await _statsService.SyncProgressAsync(userId, dto);
        return Ok();
    }
}
