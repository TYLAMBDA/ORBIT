using Microsoft.EntityFrameworkCore;
using OrbitalReader.Application.DTOs;
using OrbitalReader.Application.Interfaces;
using OrbitalReader.Core.Entities;
using OrbitalReader.Infrastructure.Data;

namespace OrbitalReader.Infrastructure.Services;

public class StatsService : IStatsService
{
    private readonly ApplicationDbContext _context;

    public StatsService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<UserStatsDto> GetUserStatsAsync(int userId)
    {
        var booksRead = await _context.ReadingProgresses
            .Where(rp => rp.UserId == userId && rp.Progress >= 100)
            .CountAsync();

        var booksPublished = await _context.Books
            .Where(b => b.UploaderId == userId)
            .CountAsync();

        var totalReadingHours = await _context.ReadingProgresses
            .Where(rp => rp.UserId == userId)
            .SumAsync(rp => rp.Progress) * 0.1;

        return new UserStatsDto(booksRead, booksPublished, totalReadingHours);
    }

    public async Task SyncProgressAsync(int userId, SyncDto dto)
    {
        foreach (var progress in dto.Progresses)
        {
            var existing = await _context.ReadingProgresses
                .FirstOrDefaultAsync(rp => rp.UserId == userId && rp.BookId == progress.BookId);

            if (existing != null)
            {
                if (progress.LastReadAt > existing.LastReadAt)
                {
                    existing.Progress = progress.Progress;
                    existing.LastReadAt = progress.LastReadAt;
                }
            }
            else
            {
                _context.ReadingProgresses.Add(new ReadingProgress
                {
                    UserId = userId,
                    BookId = progress.BookId,
                    Progress = progress.Progress,
                    LastReadAt = progress.LastReadAt
                });
            }
        }
        await _context.SaveChangesAsync();
    }
}
