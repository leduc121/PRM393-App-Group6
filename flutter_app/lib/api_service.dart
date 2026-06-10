import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io' show Platform;

class ApiService {
  // Use remote URL in Release mode, local URL in Debug mode
  static String get baseUrl {
    if (kReleaseMode) return 'https://prm393-be.onrender.com/api/v1';
    if (kIsWeb) return 'http://127.0.0.1:3000/api/v1';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api/v1';
    return 'http://127.0.0.1:3000/api/v1';
  }
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

  static Future<ApiResult> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final message = data['message'] ?? 'Xác thực thất bại';
        return ApiResult.error(message is List ? message.join(', ') : message.toString());
      }
    } catch (e) {
      return ApiResult.error('Không thể kết nối: $e');
    }
  }

  static Future<ApiResult> resendOtp({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final message = data['message'] ?? 'Gửi lại thất bại';
        return ApiResult.error(message is List ? message.join(', ') : message.toString());
      }
    } catch (e) {
      return ApiResult.error('Không thể kết nối: $e');
    }
  }

  static Future<ApiResult> logout() async {
    try {
      final headers = await _authHeaders();
      await http.post(Uri.parse('$baseUrl/auth/logout'), headers: headers);
      await clearToken();
      return ApiResult.success(null);
    } catch (e) {
      await clearToken();
      return ApiResult.success(null);
    }
  }

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

  static Future<ApiResult> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? categoryId,
    String? brandId,
    int? minPrice,
    int? maxPrice,
    String? gender,
    String? size,
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
        if (minPrice != null) 'min_price': minPrice.toString(),
        if (maxPrice != null) 'max_price': maxPrice.toString(),
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (size != null && size.isNotEmpty) 'size': size,
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

  static Future<ApiResult> createBrand(String name) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/brands'),
        headers: headers,
        body: jsonEncode({'name': name}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Thêm thương hiệu thất bại';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi thêm thương hiệu: $e');
    }
  }

  // ─── Admin Product Endpoints ───

  static Future<ApiResult> uploadProductImage(String filePath) async {
    try {
      final headers = await _authHeaders();
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/products/upload'));
      if (headers['Authorization'] != null) {
        request.headers['Authorization'] = headers['Authorization']!;
      }
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Upload thất bại';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi upload: $e');
    }
  }

  static Future<ApiResult> createProduct(Map<String, dynamic> data) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: headers,
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResult.success(responseData);
      } else {
        final msg = responseData['message'] ?? 'Thêm sản phẩm thất bại';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Không thể kết nối: $e');
    }
  }

  static Future<ApiResult> getProductDetail(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/$id'));
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(responseData);
      } else {
        final msg = responseData['message'] ?? 'Lấy chi tiết sản phẩm thất bại';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Không thể kết nối: $e');
    }
  }

  static Future<ApiResult> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final headers = await _authHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/products/$id'),
        headers: headers,
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(responseData);
      } else {
        final msg = responseData['message'] ?? 'Cập nhật thất bại';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Không thể kết nối: $e');
    }
  }

  static Future<ApiResult> deleteProduct(String id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: headers,
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(responseData);
      } else {
        final msg = responseData['message'] ?? 'Xóa thất bại';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Không thể kết nối: $e');
    }
  }
}

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
