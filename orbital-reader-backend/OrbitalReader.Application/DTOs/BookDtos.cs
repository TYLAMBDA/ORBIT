namespace OrbitalReader.Application.DTOs;

public record BookDto(int Id, string Title, string Author, string CoverColor, string Content, DateTime UploadedAt);
public record CreateBookDto(string Title, string Author, string CoverColor, string Content);
public record ExploreBookDto(string Title, string Author, string CoverColor, string Content, string Description);
