using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using OrbitalReader.Application.DTOs;
using OrbitalReader.Application.Interfaces;
using System.Security.Claims;

namespace OrbitalReader.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BooksController : ControllerBase
{
    private readonly IBookService _bookService;

    public BooksController(IBookService bookService)
    {
        _bookService = bookService;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<BookDto>>> GetBooks()
    {
        return Ok(await _bookService.GetBooksAsync());
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<BookDto>> GetBook(int id)
    {
        var book = await _bookService.GetBookByIdAsync(id);
        if (book == null) return NotFound();
        return Ok(book);
    }

    [HttpPost]
    [Authorize]
    public async Task<ActionResult<BookDto>> CreateBook(CreateBookDto dto)
    {
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var book = await _bookService.CreateBookAsync(userId, dto);
        return CreatedAtAction(nameof(GetBook), new { id = book.Id }, book);
    }

    [HttpDelete("{id}")]
    [Authorize]
    public async Task<ActionResult> DeleteBook(int id)
    {
        var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
        var result = await _bookService.DeleteBookAsync(userId, id);
        if (!result) return NotFound();
        return NoContent();
    }

    [HttpGet("explore")]
    public ActionResult<IEnumerable<ExploreBookDto>> GetExploreBooks()
    {
        var archives = new List<ExploreBookDto>
        {
            new ExploreBookDto(
                "The War of the Worlds", 
                "H.G. Wells", 
                "0xFFFF0000", 
                "No one would have believed in the last years of the nineteenth century that this world was being watched keenly and closely by intelligences greater than man's and yet as mortal as his own...",
                "A classic tale of Martian invasion that defined the genre."
            ),
            new ExploreBookDto(
                "20,000 Leagues Under the Sea", 
                "Jules Verne", 
                "0xFF0000FF", 
                "The year 1866 was signalised by a remarkable incident, a mysterious and puzzling phenomenon, which doubtless no one has yet forgotten...",
                "Journey into the depths of the ocean with Captain Nemo."
            ),
             new ExploreBookDto(
                "Frankenstein", 
                "Mary Shelley", 
                "0xFF00FF00", 
                "You will rejoice to hear that no disaster has accompanied the commencement of an enterprise which you have regarded with such evil forebodings...",
                "The cautionary tale of a scientist playing god."
            ),
            new ExploreBookDto(
                "The Time Machine", 
                "H.G. Wells", 
                "0xFFFFA500", 
                "The Time Traveller (for so it will be convenient to speak of him) was expounding a recondite matter to us...",
                "Travel to the year 802,701 and witness the future of humanity."
            )
        };

        return Ok(archives);
    }
}
