import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://prm393-be.onrender.com/api/v1';
  static const String _tokenKey = 'jwt_access_token';

  // ─── Token Management ───

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Auth Endpoints ───

  /// POST /auth/register
  /// Returns: { user: {...} } or error
  static Future<ApiResult> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        final message = data['message'] ?? 'Đăng ký thất bại';
        return ApiResult.error(
          message is List ? message.join(', ') : message.toString(),
        );
      }
    } catch (e) {
      return ApiResult.error('Không thể kết nối đến server: $e');
    }
  }

  /// POST /auth/login
  /// Returns: { accessToken: "...", user: {...} }
  static Future<ApiResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save JWT token. The current NestJS backend returns accessToken.
        final token = data['accessToken'] ?? data['access_token'];
        if (token != null) {
          await saveToken(token.toString());
        }
        return ApiResult.success(data);
      } else {
        final message = data['message'] ?? 'Đăng nhập thất bại';
        return ApiResult.error(
          message is List ? message.join(', ') : message.toString(),
        );
      }
    } catch (e) {
      return ApiResult.error('Không thể kết nối đến server: $e');
    }
  }

  /// POST /auth/logout
  static Future<ApiResult> logout() async {
    try {
      final headers = await _authHeaders();
      await http.post(Uri.parse('$baseUrl/auth/logout'), headers: headers);
      await clearToken();
      return ApiResult.success(null);
    } catch (e) {
      // Even if server call fails, clear local token
      await clearToken();
      return ApiResult.success(null);
    }
  }

  /// GET /auth/me
  /// Returns user info if token is valid
  static Future<ApiResult> getMe() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResult.success(data);
      } else {
        return ApiResult.error('Token hết hạn');
      }
    } catch (e) {
      return ApiResult.error('Không thể kết nối: $e');
    }
  }

  // ─── Products Endpoints ───

  /// GET /products
  static Future<ApiResult> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
    String? brandId,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        // ignore: use_null_aware_elements
        if (categoryId case final id?) 'category_id': id,
        // ignore: use_null_aware_elements
        if (brandId case final id?) 'brand_id': id,
      };

      final uri = Uri.parse(
        '$baseUrl/products',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResult.success(data);
      } else {
        return ApiResult.error('Không thể tải danh sách sản phẩm');
      }
    } catch (e) {
      return ApiResult.error('Không thể kết nối: $e');
    }
  }

  /// GET /categories
  static Future<ApiResult> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResult.success(data);
      } else {
        return ApiResult.error('Không thể tải danh mục');
      }
    } catch (e) {
      return ApiResult.error('Không thể kết nối: $e');
    }
  }

  /// GET /brands
  static Future<ApiResult> getBrands() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/brands'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResult.success(data);
      } else {
        return ApiResult.error('Không thể tải thương hiệu');
      }
    } catch (e) {
      return ApiResult.error('Không thể kết nối: $e');
    }
  }
}

/// Simple result wrapper for API calls
class ApiResult {
  final bool isSuccess;
  final dynamic data;
  final String? errorMessage;

  ApiResult._({required this.isSuccess, this.data, this.errorMessage});

  factory ApiResult.success(dynamic data) =>
      ApiResult._(isSuccess: true, data: data);

  factory ApiResult.error(String message) =>
      ApiResult._(isSuccess: false, errorMessage: message);
}
