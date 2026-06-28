import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io' show Platform;

class ApiService {
  // Use remote URL in Release mode, local URL in Debug mode
  static String get baseUrl {
    // Trỏ thẳng về link Render đã deploy (dùng cho cả Debug và Release)
    return 'https://prm393-be.onrender.com/api/v1';

    // Nếu sau này bạn muốn chạy test với Backend dưới máy Local, hãy dùng cụm dưới:
    // if (kReleaseMode) return 'https://prm393-be.onrender.com/api/v1';
    // if (kIsWeb) return 'http://127.0.0.1:3000/api/v1';
    // if (Platform.isAndroid) return 'http://10.10.3.39:3000/api/v1';
    // return 'http://127.0.0.1:3000/api/v1';
  }
  static const String _tokenKey = 'jwt_access_token';
  static const Duration _timeout = Duration(seconds: 120);

  /// Gửi ping "đánh thức" server Render (gọi khi mở app để server bắt đầu cold start sớm)
  static Future<void> warmUp() async {
    try {
      http.get(Uri.parse('$baseUrl/products?limit=1')).timeout(
        const Duration(seconds: 120),
      );
    } catch (_) {
      // Bỏ qua lỗi - chỉ cần gửi request để đánh thức server
    }
  }

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
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        final message = data['message'] ?? 'Đăng ký thất bại';
        return ApiResult.error(
          message is List ? message.join(', ') : message.toString(),
        );
      }
    } on TimeoutException {
      return ApiResult.error('Server phản hồi quá lâu. Vui lòng thử lại.');
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
      ).timeout(_timeout);

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
    } on TimeoutException {
      return ApiResult.error('Server phản hồi quá lâu. Vui lòng thử lại.');
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
      ).timeout(_timeout);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = data['accessToken'] ?? data['access_token'];
        if (token != null) {
          await saveToken(token.toString());
        }
        return ApiResult.success(data);
      } else {
        final message = data['message'] ?? 'Xác thực thất bại';
        return ApiResult.error(message is List ? message.join(', ') : message.toString());
      }
    } on TimeoutException {
      return ApiResult.error('Server phản hồi quá lâu. Vui lòng thử lại.');
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
      ).timeout(_timeout);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final message = data['message'] ?? 'Gửi lại thất bại';
        return ApiResult.error(message is List ? message.join(', ') : message.toString());
      }
    } on TimeoutException {
      return ApiResult.error('Server phản hồi quá lâu. Vui lòng thử lại.');
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
      ).timeout(_timeout);

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
      ).timeout(_timeout);

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
      ).timeout(_timeout);

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
      ).timeout(_timeout);

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
      final response = await http.get(Uri.parse('$baseUrl/products/$id')).timeout(_timeout);
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

  // ─── Cart Endpoints ───

  static Future<ApiResult> getCart() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: headers,
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không thể tải giỏ hàng';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi tải giỏ hàng: $e');
    }
  }

  static Future<ApiResult> addToCart({
    required String variantId,
    required int quantity,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/cart/items'),
        headers: headers,
        body: jsonEncode({
          'variantId': variantId,
          'quantity': quantity,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không thể thêm vào giỏ hàng';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi thêm vào giỏ hàng: $e');
    }
  }

  static Future<ApiResult> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/cart/items/$itemId'),
        headers: headers,
        body: jsonEncode({
          'quantity': quantity,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không thể cập nhật giỏ hàng';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi cập nhật giỏ hàng: $e');
    }
  }

  static Future<ApiResult> deleteCartItem({
    required String itemId,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/items/$itemId'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không thể xóa mặt hàng';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi xóa mặt hàng: $e');
    }
  }

  static Future<ApiResult> clearCart() async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/cart'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không thể xóa toàn bộ giỏ hàng';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi xóa toàn bộ giỏ hàng: $e');
    }
  }

  // ─── Orders Endpoints ───

  static Future<ApiResult> createOrder({
    required String addressId,
    required String paymentMethod,
    String? note,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: headers,
        body: jsonEncode({
          'addressId': addressId,
          'paymentMethod': paymentMethod,
          if (note != null && note.isNotEmpty) 'note': note,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Đặt hàng thất bại';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi đặt hàng: $e');
    }
  }

  static Future<ApiResult> createStripeCheckoutSession(String orderId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/payment/create-checkout-session/$orderId'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không thể khởi tạo thanh toán Stripe';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi tạo phiên thanh toán: $e');
    }
  }

  static Future<ApiResult> getMyOrders() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không thể tải danh sách đơn hàng';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi tải danh sách đơn hàng: $e');
    }
  }

  static Future<ApiResult> getOrderById(String id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$id'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không thể tải chi tiết đơn hàng';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi tải chi tiết đơn hàng: $e');
    }
  }

  static Future<ApiResult> cancelOrder(String id) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/orders/$id'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Hủy đơn hàng thất bại';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi hủy đơn hàng: $e');
    }
  }

  static Future<ApiResult> updateOrderStatus(String id, String status) async {
    try {
      final headers = await _authHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$id/status'),
        headers: headers,
        body: jsonEncode({'status': status}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Cập nhật trạng thái thất bại';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi cập nhật trạng thái đơn hàng: $e');
    }
  }

  // ─── Users & Addresses Endpoints ───

  static Future<ApiResult> getUserProfile(String uid) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$uid'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không thể lấy thông tin người dùng';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi lấy thông tin người dùng: $e');
    }
  }

  static Future<ApiResult> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      final headers = await _authHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$uid'),
        headers: headers,
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(responseData);
      } else {
        final msg = responseData['message'] ?? 'Cập nhật profile thất bại';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi cập nhật profile: $e');
    }
  }

  static Future<ApiResult> getAddresses(String uid) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$uid/addresses'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không thể tải danh sách địa chỉ';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi tải danh sách địa chỉ: $e');
    }
  }

  static Future<ApiResult> createAddress({
    required String uid,
    required String recipientName,
    required String phone,
    required String street,
    String? ward,
    String? district,
    String? city,
    bool isDefault = false,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/users/$uid/addresses'),
        headers: headers,
        body: jsonEncode({
          'recipientName': recipientName,
          'phone': phone,
          'street': street,
          if (ward != null && ward.isNotEmpty) 'ward': ward,
          if (district != null && district.isNotEmpty) 'district': district,
          if (city != null && city.isNotEmpty) 'city': city,
          'isDefault': isDefault,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không thể tạo địa chỉ';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi tạo địa chỉ: $e');
    }
  }

  static Future<ApiResult> updateAddress(String addressId, Map<String, dynamic> data) async {
    try {
      final headers = await _authHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/addresses/$addressId'),
        headers: headers,
        body: jsonEncode(data),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(responseData);
      } else {
        final msg = responseData['message'] ?? 'Không thể cập nhật địa chỉ';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi cập nhật địa chỉ: $e');
    }
  }

  static Future<ApiResult> deleteAddress(String addressId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/addresses/$addressId'),
        headers: headers,
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResult.success(data);
      } else {
        final msg = data['message'] ?? 'Không thể xóa địa chỉ';
        return ApiResult.error(msg is List ? msg.join(', ') : msg.toString());
      }
    } catch (e) {
      return ApiResult.error('Lỗi xóa địa chỉ: $e');
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
