import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Use localhost for Windows. For Android emulator use 10.0.2.2
  // Note: Backend is running on http://localhost:5063 (from previous logs)
  static const String baseUrl = 'http://localhost:5063/api';

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<dynamic> register(String username, String email, String password) async {
    print("DEBUG: Registering $username / $email at $_dio.options.baseUrl");
    try {
      final response = await _dio.post('/Auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });
      print("DEBUG: Register Response: ${response.statusCode}");
      print("DEBUG: Register Data: ${response.data}");
      return response.data;
    } catch (e) {
      if (e is DioException) {
         print("DEBUG: Register DioError: ${e.response?.statusCode} - ${e.response?.data}");
      } else {
         print("DEBUG: Register Error: $e");
      }
      rethrow;
    }
  }

  Future<dynamic> login(String email, String password) async {
    print("DEBUG: Logging in $email at ${_dio.options.baseUrl}");
    try {
      final response = await _dio.post('/Auth/login', data: {
        'email': email,
        'password': password,
      });
      print("DEBUG: Login Response: ${response.statusCode}");
      print("DEBUG: Login Data: ${response.data}");
      return response.data;
    } catch (e) {
       if (e is DioException && e.response?.data != null) {
         print("DEBUG: Login DioError: ${e.response?.statusCode} - ${e.response?.data}");
         throw Exception(e.response?.data);
       } else {
         print("DEBUG: Login Error: $e");
       }
      rethrow;
    }
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  // Book Endpoints
  Future<List<dynamic>> getBooks() async {
     try {
      final response = await _dio.get('/Books');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBook(String id) async {
    try {
      await _dio.delete('/Books/$id');
    } catch (e) {
      if (e is DioException) {
         print("DEBUG: Delete DioError: ${e.response?.statusCode}");
      }
      rethrow;
    }
  }

  Future<dynamic> createBook(String title, String author, String content, String coverColor) async {
    try {
      final response = await _dio.post('/Books', data: {
        'title': title,
        'author': author,
        'content': content,
        'coverColor': coverColor
      });
      return response.data;
    } catch (e) {
      print("Create Book Failed: $e");
      rethrow;
    }
  }

  Future<List<dynamic>> getExploreBooks() async {
    try {
      final response = await _dio.get('/Books/explore');
      return response.data;
    } catch (e) {
      if (e is DioException) {
          print("DEBUG: Explore DioError: ${e.response?.statusCode}");
      }
      rethrow;
    }
  }
}
