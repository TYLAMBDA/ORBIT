using Microsoft.EntityFrameworkCore;
using OrbitalReader.Application.DTOs;
using OrbitalReader.Application.Interfaces;
using OrbitalReader.Core.Entities;
using OrbitalReader.Infrastructure.Data;

namespace OrbitalReader.Infrastructure.Services;

public class BookService : IBookService
{
    private readonly ApplicationDbContext _context;

    public BookService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<BookDto> CreateBookAsync(int userId, CreateBookDto dto)
    {
        var book = new Book
        {
            Title = dto.Title,
            Author = dto.Author,
            CoverColor = dto.CoverColor,
            Content = dto.Content,
            UploaderId = userId,
            UploadedAt = DateTime.UtcNow
        };

        _context.Books.Add(book);
        await _context.SaveChangesAsync();

        return new BookDto(book.Id, book.Title, book.Author, book.CoverColor, book.Content, book.UploadedAt);
    }

    public async Task<IEnumerable<BookDto>> GetBooksAsync()
    {
        return await _context.Books
            .Select(b => new BookDto(b.Id, b.Title, b.Author, b.CoverColor, b.Content, b.UploadedAt))
            .ToListAsync();
    }

    public async Task<BookDto?> GetBookByIdAsync(int id)
    {
        var book = await _context.Books.FindAsync(id);
        if (book == null) return null;
        return new BookDto(book.Id, book.Title, book.Author, book.CoverColor, book.Content, book.UploadedAt);
    }

    public async Task<bool> DeleteBookAsync(int userId, int bookId)
    {
        var book = await _context.Books.FindAsync(bookId);
        if (book == null || book.UploaderId != userId) return false;

        _context.Books.Remove(book);
        await _context.SaveChangesAsync();
        return true;
    }
}
