using System;

namespace OrbitalReader.Core.Entities;

public class ReadingProgress
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public int BookId { get; set; }
    public Book Book { get; set; } = null!;
    public int Progress { get; set; } // Percentage or Page Number
    public DateTime LastReadAt { get; set; } = DateTime.UtcNow;
}
