namespace OrbitalReader.Application.DTOs;

public record ReadingProgressDto(int BookId, int Progress, DateTime LastReadAt);
public record SyncDto(List<ReadingProgressDto> Progresses);
public record UserStatsDto(int BooksRead, int BooksPublished, double TotalReadingHours);
