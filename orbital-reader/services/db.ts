
import { Book, User, Language } from '../types';

const DB_KEYS = {
    BOOKS: 'orbital_books',
    USER: 'orbital_user',
    SETTINGS: 'orbital_settings',
    CONTENT_CACHE: 'orbital_content_cache'
};

export class OrbitalDB {
    static init() {
        if (!localStorage.getItem(DB_KEYS.BOOKS)) {
            const initialBooks: Book[] = [
                { id: '1', title: "The Three-Body Problem", author: "Cixin Liu", coverColor: "bg-blue-600", progress: 65 },
                { id: '2', title: "Dune", author: "Frank Herbert", coverColor: "bg-orange-600", progress: 20 }
            ];
            this.saveBooks(initialBooks);
        }
    }

    static getBooks(): Book[] {
        const data = localStorage.getItem(DB_KEYS.BOOKS);
        return data ? JSON.parse(data) : [];
    }

    static saveBooks(books: Book[]) {
        localStorage.setItem(DB_KEYS.BOOKS, JSON.stringify(books));
    }

    static addBook(book: Book) {
        const books = this.getBooks();
        if (!books.find(b => b.id === book.id)) {
            books.push(book);
            this.saveBooks(books);
        }
    }

    static removeBook(bookId: string) {
        const books = this.getBooks().filter(b => b.id !== bookId);
        this.saveBooks(books);
        
        // Also clear content cache for this book
        const cache = localStorage.getItem(DB_KEYS.CONTENT_CACHE);
        if (cache) {
            const parsed = JSON.parse(cache);
            delete parsed[bookId];
            localStorage.setItem(DB_KEYS.CONTENT_CACHE, JSON.stringify(parsed));
        }
    }

    static updateBookProgress(bookId: string, progress: number) {
        const books = this.getBooks();
        const index = books.findIndex(b => b.id === bookId);
        if (index !== -1) {
            books[index].progress = progress;
            this.saveBooks(books);
        }
    }

    static getBookContent(bookId: string): string[] | null {
        const cache = localStorage.getItem(DB_KEYS.CONTENT_CACHE);
        if (!cache) return null;
        const parsed = JSON.parse(cache);
        return parsed[bookId] || null;
    }

    static saveBookContent(bookId: string, content: string[]) {
        const cache = localStorage.getItem(DB_KEYS.CONTENT_CACHE) || '{}';
        const parsed = JSON.parse(cache);
        parsed[bookId] = content;
        localStorage.setItem(DB_KEYS.CONTENT_CACHE, JSON.stringify(parsed));
    }

    static getUser(): User | null {
        const data = localStorage.getItem(DB_KEYS.USER);
        return data ? JSON.parse(data) : null;
    }

    static saveUser(user: User | null) {
        if (user) {
            localStorage.setItem(DB_KEYS.USER, JSON.stringify(user));
        } else {
            localStorage.removeItem(DB_KEYS.USER);
        }
    }
}
