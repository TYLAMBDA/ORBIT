using OrbitalReader.Application.DTOs;

namespace OrbitalReader.Application.Interfaces;

public interface IBookService
{
    Task<BookDto> CreateBookAsync(int userId, CreateBookDto dto);
    Task<IEnumerable<BookDto>> GetBooksAsync();
    Task<BookDto?> GetBookByIdAsync(int id);
    Task<bool> DeleteBookAsync(int userId, int bookId);
}
