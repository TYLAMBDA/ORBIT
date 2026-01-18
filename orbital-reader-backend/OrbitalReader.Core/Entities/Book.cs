using System;

namespace OrbitalReader.Core.Entities;

public class Book
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Author { get; set; } = string.Empty;
    public string CoverColor { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty; // Storing text directly for now
    public int? UploaderId { get; set; }
    public User? Uploader { get; set; }
    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;
}
