using System;

namespace OrbitalReader.Core.Entities;

public class User
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string Avatar { get; set; } = string.Empty; // Store Tailwind class or URL
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<ReadingProgress> ReadingProgresses { get; set; } = new List<ReadingProgress>();
    public ICollection<Book> UploadedBooks { get; set; } = new List<Book>();
}
