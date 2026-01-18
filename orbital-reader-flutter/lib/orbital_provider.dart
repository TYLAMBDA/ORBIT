import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'types.dart';
import 'dart:async';
import 'services/api_service.dart';
import 'database/database.dart' as drift_db;
import 'package:drift/drift.dart' as drift;



class OrbitalProvider with ChangeNotifier {
  // App State
  DockPosition _dockPosition = DockPosition.center;
  DockPosition _preferredDock = DockPosition.left;
  String? _activeItemId;
  Book? _currentBook;
  
  // Auth & Offline State
  User? _user;
  bool _isOfflineMode = false;

  // New Feature State
  bool _autoHide = false;
  bool _edgeNav = false;
  Language _language = Language.en;

  // Interaction State
  bool _isInteracting = false;
  final Set<String> _activeHovers = {};
  Timer? _debounceTimer;
  bool _forceWake = false;

  // Services
  final ApiService _apiService = ApiService();
  final drift_db.AppDatabase _db = drift_db.AppDatabase();

  drift_db.AppDatabase get db => _db;


  // Getters
  DockPosition get dockPosition => _dockPosition;
  DockPosition get preferredDock => _preferredDock;
  String? get activeItemId => _activeItemId;
  Book? get currentBook => _currentBook;
  User? get user => _user;
  bool get isOfflineMode => _isOfflineMode;
  bool get autoHide => _autoHide;
  bool get edgeNav => _edgeNav;
  Language get language => _language;
  bool get isInteracting => _isInteracting || _forceWake;

  // Logic
  void setDockPosition(DockPosition pos) {
    _dockPosition = pos;
    notifyListeners();
  }

  void setPreferredDock(DockPosition pos) {
    _preferredDock = pos;
    if (_dockPosition != DockPosition.center) {
      _dockPosition = pos;
      if (_autoHide) {
        // Force wake for 1 second when changing dock to ensure visibility
        _forceWake = true;
        notifyListeners();
        
        Timer(const Duration(milliseconds: 1000), () {
          _forceWake = false;
          _evaluateInteractionState();
        });
      }
    }
    notifyListeners();
  }

  void setActiveItemId(String? id) {
    _activeItemId = id;
    notifyListeners();
  }

  List<Book> _libraryBooks = [];
  List<Book> get libraryBooks => _libraryBooks;

  void setCurrentBook(Book book) {
    _currentBook = book;
    notifyListeners();
  }

  Future<void> fetchBooks() async {
    if (_isOfflineMode) {
       final dbBooks = await _db.allBooks;
       _libraryBooks = dbBooks.map((b) => Book(
         id: b.id.toString(),
         title: b.title,
         author: b.author,
         coverColor: b.coverColor,
         parsedColor: _parseColor(b.coverColor),
         progress: 0, 
       )).toList();
    } else {
      try {
        final data = await _apiService.getBooks();
        _libraryBooks = List<Book>.from(data.map((b) => Book(
          id: b['id'].toString(),
          title: b['title'],
          author: b['author'],
          coverColor: b['coverColor'],
          parsedColor: _parseColor(b['coverColor']),
          progress: 0,
        )));
        
        // Sync to local DB (simple cache for now)
        // In real app, we'd enable incremental sync
      } catch (e) {
        print("Fetch Books Error: $e");
      }
    }
    notifyListeners();
  }

  Future<void> uploadBook(String title, String author, String content) async {
      // Pick a random color for now
      final colors = ['bg-red-500', 'bg-blue-500', 'bg-green-500', 'bg-purple-500', 'bg-yellow-500'];
      final color = colors[DateTime.now().microsecond % colors.length];

      try {
        await _apiService.createBook(title, author, content, color);
        await fetchBooks(); // Refresh list
      } catch (e) {
        print("Upload Error: $e");
        rethrow;
      }
  }

  Future<void> deleteBook(String id) async {
    try {
      if (_isOfflineMode) {
        // Implement offline delete if needed
      } else {
        await _apiService.deleteBook(id);
        _libraryBooks.removeWhere((b) => b.id == id);
        notifyListeners();
      }
    } catch (e) {
      print("Delete Provider Error: $e");
      rethrow;
    }
  }

  // Explore Logic
  List<ExploreBook> _exploreBooks = [];
  List<ExploreBook> get exploreBooks => _exploreBooks;
  bool _isExploreLoading = false;
  bool get isExploreLoading => _isExploreLoading;

  Future<void> fetchExploreBooks() async {
    _isExploreLoading = true;
    notifyListeners();
    try {
      final data = await _apiService.getExploreBooks();
      _exploreBooks = List<ExploreBook>.from(data.map((b) => ExploreBook(
        title: b['title'],
        author: b['author'],
        coverColor: b['coverColor'],
        content: b['content'],
        description: b['description'],
        parsedColor: _parseColor(b['coverColor']),
      )));
    } catch (e) {
      print("Fetch Explore Error: $e");
    } finally {
      _isExploreLoading = false;
      notifyListeners();
    }
  }

  Future<void> importBook(ExploreBook book) async {
    // Re-use upload logic
    await uploadBook(book.title, book.author, book.content); 
    // Maybe show a success message or just refresh library
  }

  // Color Parsing Helper





  Color _parseColor(String colorName) {
    // Simple mock parser to keep it working
    switch (colorName) {
      case 'bg-red-500': return Colors.red;
      case 'bg-blue-500': return Colors.blue;
      case 'bg-green-500': return Colors.green;
      case 'bg-yellow-500': return Colors.orange; // Adjusted for readability
      case 'bg-purple-500': return Colors.purple;
      default: return Colors.grey;
    }
  }


  void setIsOfflineMode(bool value) {
    _isOfflineMode = value;
    notifyListeners();
  }
  
  void setLanguage(Language lang) {
    _language = lang;
    notifyListeners();
  }

  void setAutoHide(bool value) {
    _autoHide = value;
    if (!_autoHide && _edgeNav) {
      _edgeNav = false;
    }
    notifyListeners();
  }
  
  void setEdgeNav(bool value) {
    _edgeNav = value;
    if (!value) {
      _preferredDock = DockPosition.left;
      if (_dockPosition != DockPosition.center) {
        _dockPosition = DockPosition.left;
      }
    }
    notifyListeners();
  }

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  // Generalized Hover Handler
  void setHover(String sourceId, bool isHovering) {
    if (isHovering) {
      _activeHovers.add(sourceId);
    } else {
      _activeHovers.remove(sourceId);
    }
    _evaluateInteractionState();
  }

  void _evaluateInteractionState() {
    // If explicit force wake is on, do nothing (state is already true)
    if (_forceWake) return;

    if (_activeHovers.isNotEmpty) {
      _debounceTimer?.cancel();
      if (!_isInteracting) {
        _isInteracting = true;
        notifyListeners();
      }
    } else {
      // Debounce the hide to prevent jitter when moving between overlapping widgets
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 150), () {
        if (_activeHovers.isEmpty && !_forceWake) {
          _isInteracting = false;
          notifyListeners();
        }
      });
    }
  }

  // Deprecated but kept for compatibility if needed (mapped to generic)
  void handleInteractionStart() => setHover('generic', true);
  void handleInteractionEnd() => setHover('generic', false);

  void handleMenuItemClick(MenuItem item) {
    // 1. OFFLINE MODE HANDLER
    if (item.id == 'offline') {
      _isOfflineMode = true;
      _activeItemId = null;
      _dockPosition = DockPosition.center;
      notifyListeners();
      return;
    }

    // 2. AUTH CHECK INTERCEPTION
    if (_user == null && !_isOfflineMode) {
      _dockPosition = DockPosition.center;
      _activeItemId = 'auth';
      notifyListeners();
      return;
    }

    // 3. NORMAL NAVIGATION
    if (_activeItemId == item.id) return;

    if (!_edgeNav) {
      _dockPosition = _preferredDock;
    }
    _activeItemId = item.id;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final data = await _apiService.login(email, password);
      // Backend returns: { "token": "...", "username": "...", "email": "..." }
      await _apiService.saveToken(data['token']);
      
      final loggedInUser = User(
        username: data['username'],
        email: data['email'],
        avatar: 'bg-blue-500', // Default or from backend
        parsedAvatarColor: Colors.blue, 
        stats: UserStats(totalReadingHours: 0, booksRead: [], booksPublished: [])
      );

      _user = loggedInUser;
      _isOfflineMode = false;
      _activeItemId = null;
      _dockPosition = DockPosition.center;
      notifyListeners();
    } catch (e) {
      print("Login Error: $e");
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      final data = await _apiService.register(username, email, password);
      await _apiService.saveToken(data['token']);
       
      final loggedInUser = User(
        username: data['username'],
        email: data['email'],
        avatar: 'bg-green-500',
        parsedAvatarColor: Colors.green,
        stats: UserStats(totalReadingHours: 0, booksRead: [], booksPublished: [])
      );

      _user = loggedInUser;
      _isOfflineMode = false;
      _activeItemId = null;
      _dockPosition = DockPosition.center;
      notifyListeners();
    } catch (e) {
      print("Register Error: $e");
      rethrow;
    }
  }

  void handleLogout() {
    _apiService.logout();
    _user = null;
    _isOfflineMode = false;
    _activeItemId = 'auth';
    _dockPosition = DockPosition.center;
    notifyListeners();
  }


  void handleBookSelect(Book book) {
    _currentBook = book;
    setDockPosition(_preferredDock);
    setActiveItemId('reader');
  }

  void handleEdgeEnter(DockPosition edge) {
      if (_dockPosition == DockPosition.center) return;
      if (_edgeNav) {
          _dockPosition = edge;
          notifyListeners();
      }
      if (_autoHide) {
         if (_edgeNav || edge == _dockPosition) {
             setHover('edge', true);
         }
      }
  }

  void handleEdgeExit() {
    setHover('edge', false);
  }

  // Translation Helper
  Map<String, String> get t {
    if (_language == Language.en) {
      return {
        'library': 'Library', 'reader': 'Continue', 'search': 'Explore',
        'profile': 'Profile', 'settings': 'Settings', 'offline': 'Offline Mode', 'login': 'Login',
        'status_online': 'System Online', 'status_offline': 'Offline Mode', 'status_guest': 'Guest Access'
      };
    } else {
      return {
        'library': '书库', 'reader': '继续阅读', 'search': '探索',
        'profile': '个人中心', 'settings': '设置', 'offline': '离线模式', 'login': '登录',
        'status_online': '系统在线', 'status_offline': '离线模式', 'status_guest': '游客访问'
      };
    }
  }
}
