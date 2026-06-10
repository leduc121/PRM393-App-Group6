import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';


class SportZoneState extends ChangeNotifier {
  User? currentUser;
  String selectedCategory = 'Tất cả';
  String? selectedCategoryId;
  String selectedBrand = 'Tất cả';
  String? selectedBrandId;
  bool isBotTyping = false;
  int selectedTabIndex = 0;

  int? filterMinPrice;
  int? filterMaxPrice;
  String? filterGender;
  String? filterSize;


  // API-loaded data
  List<Product> apiProducts = [];
  List<Category> apiCategories = [];
  List<Brand> apiBrands = [];
  bool isLoadingProducts = false;
  bool isLoadingAuth = false;
  String? authError;

  final List<CartItem> cartItems = [];
  final List<NotificationItem> notifications = [
    NotificationItem(
      title: 'Đơn hàng đã được giao',
      content:
          'Đơn hàng #SZ123 của bạn đã giao thành công tại địa chỉ mặc định. Cảm ơn bạn đã tin dùng SportZone.',
      timeAgo: '2 giờ trước',
      category: 'DELIVERY',
      isRead: false,
    ),
    NotificationItem(
      title: 'Drop Alert: Jordan Retro 4',
      content:
          'Phiên bản giới hạn sắp có mặt tại cửa hàng sau 15 phút nữa. Chuẩn bị thanh toán ngay!',
      timeAgo: '4 giờ trước',
      category: 'ALERT',
      isRead: false,
    ),
    NotificationItem(
      title: 'Voucher 20% sắp hết hạn',
      content:
          'Mã SPORT20 của bạn sẽ hết hiệu lực vào cuối ngày hôm nay. Đừng bỏ lỡ!',
      timeAgo: 'Hôm qua',
      category: 'PROMO',
      isRead: true,
    ),
    NotificationItem(
      title: 'Ưu đãi sinh nhật cho bạn',
      content:
          'Chúc mừng sinh nhật! Nhận ngay món quà bí mật trong ví voucher của bạn.',
      timeAgo: '2 ngày trước',
      category: 'ALERT',
      isRead: false,
    ),
  ];

  final List<ChatMessage> chatMessages = [
    ChatMessage(
      message:
          'Chào bạn, nhân viên sẽ hỗ trợ bạn ngay trong giây lát. Vui lòng cho biết size chân thông thường của bạn nhé!',
      isUser: false,
    ),
  ];

  int _nextCartId = 1;

  // ─── Auth Methods (API) ───

  /// Try auto-login using saved token
  Future<bool> tryAutoLogin() async {
    final token = await ApiService.getToken();
    if (token == null) return false;

    final result = await ApiService.getMe();
    if (result.isSuccess && result.data != null) {
      currentUser = User.fromJson(result.data as Map<String, dynamic>);
      notifyListeners();
      return true;
    } else {
      await ApiService.clearToken();
      return false;
    }
  }

  /// Login via API
  Future<String?> loginAsync(String email, String password) async {
    isLoadingAuth = true;
    authError = null;
    notifyListeners();

    final result = await ApiService.login(email: email, password: password);

    isLoadingAuth = false;

    if (result.isSuccess) {
      final data = result.data as Map<String, dynamic>;
      if (data['user'] != null) {
        currentUser = User.fromJson(data['user'] as Map<String, dynamic>);
      }
      notifyListeners();
      return null; // no error
    } else {
      authError = result.errorMessage;
      notifyListeners();
      return result.errorMessage;
    }
  }

  /// Register via API
  Future<String?> registerAsync({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    isLoadingAuth = true;
    authError = null;
    notifyListeners();

    final result = await ApiService.register(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
    );

    isLoadingAuth = false;

    if (result.isSuccess) {
      notifyListeners();
      return null;
    } else {
      authError = result.errorMessage;
      notifyListeners();
      return result.errorMessage;
    }
  }

  Future<void> logoutAsync() async {
    await ApiService.logout();
    currentUser = null;
    apiProducts.clear();
    selectedTabIndex = 0;
    notifyListeners();
  }

  Future<String?> verifyOtpAsync(String email, String otp) async {
    isLoadingAuth = true;
    authError = null;
    notifyListeners();

    final result = await ApiService.verifyOtp(email: email, otp: otp);

    isLoadingAuth = false;
    notifyListeners();

    if (result.isSuccess) {
      return null; // success
    } else {
      return result.errorMessage ?? 'Xác thực thất bại';
    }
  }

  Future<String?> resendOtpAsync(String email) async {
    isLoadingAuth = true;
    authError = null;
    notifyListeners();

    final result = await ApiService.resendOtp(email: email);

    isLoadingAuth = false;
    notifyListeners();

    if (result.isSuccess) {
      return null; // success
    } else {
      return result.errorMessage ?? 'Gửi lại mã thất bại';
    }
  }

  // Keep legacy methods for backward compat (used nowhere now, but safe)
  bool login(String username, String password) {
    if (username.isNotEmpty && password.length >= 4) {
      currentUser = User(
        uid: '',
        name: username.split('@').first,
        email: username,
        phone: '0900000000',
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  bool register(String name, String email, String phone, String password) {
    if (name.isNotEmpty &&
        email.isNotEmpty &&
        phone.isNotEmpty &&
        password.length >= 4) {
      currentUser = User(uid: '', name: name, email: email, phone: phone);
      notifyListeners();
      return true;
    }
    return false;
  }

  // ─── Products / Categories / Brands (API) ───

  Future<void> fetchProducts({String? categoryId, String? brandId, int? minPrice, int? maxPrice, String? gender, String? size}) async {
    isLoadingProducts = true;
    notifyListeners();

    final result = await ApiService.getProducts(
      limit: 50,
      categoryId: categoryId,
      brandId: brandId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      gender: gender,
      size: size,
    );

    if (result.isSuccess && result.data != null) {
      final data = result.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      apiProducts = items
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    isLoadingProducts = false;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    final result = await ApiService.getCategories();
    if (result.isSuccess && result.data != null) {
      final list = result.data as List<dynamic>;
      apiCategories = list
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> fetchBrands() async {
    final result = await ApiService.getBrands();
    if (result.isSuccess && result.data != null) {
      final list = result.data as List<dynamic>;
      apiBrands = list
          .map((json) => Brand.fromJson(json as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  // ─── Category / Cart / Chat / Notifications ───

  void selectCategory(String value, {String? categoryId}) {
    selectedCategory = value;
    selectedCategoryId = categoryId;
    fetchProducts(categoryId: categoryId, brandId: selectedBrandId, minPrice: filterMinPrice, maxPrice: filterMaxPrice, gender: filterGender, size: filterSize);
  }

  void selectBrand(String value, {String? brandId}) {
    selectedBrand = value;
    selectedBrandId = brandId;
    fetchProducts(categoryId: selectedCategoryId, brandId: brandId, minPrice: filterMinPrice, maxPrice: filterMaxPrice, gender: filterGender, size: filterSize);
  }


  void applyFilters({
    int? minPrice, 
    int? maxPrice, 
    String? gender, 
    String? size,
    String? categoryName,
    String? categoryId,
    String? brandName,
    String? brandId,
  }) {
    filterMinPrice = minPrice;
    filterMaxPrice = maxPrice;
    filterGender = gender;
    filterSize = size;

    if (categoryName != null) {
      selectedCategory = categoryName;
      selectedCategoryId = categoryId;
    }
    if (brandName != null) {
      selectedBrand = brandName;
      selectedBrandId = brandId;
    }

    fetchProducts(
      categoryId: selectedCategoryId,
      brandId: selectedBrandId,
      minPrice: filterMinPrice,
      maxPrice: filterMaxPrice,
      gender: filterGender,
      size: filterSize,
    );
  }

  void addToCart(
    Product product, {
    String size = '40',
    String color = 'Black',
    int quantity = 1,
  }) {
    final existing = cartItems.firstWhere(
      (item) =>
          item.productId == product.id &&
          item.size == size &&
          item.color == color,
      orElse: () => CartItem.empty(),
    );
    if (existing.id != 0) {
      existing.quantity += quantity;
    } else {
      cartItems.add(
        CartItem(
          id: _nextCartId++,
          productId: product.id,
          name: product.name,
          price: product.price,
          imageUrl: product.imageUrl,
          quantity: quantity,
          size: size,
          color: color,
        ),
      );
    }
    notifyListeners();
  }

  void updateCartItemQuantity(int id, int quantity) {
    final item = cartItems.firstWhere(
      (it) => it.id == id,
      orElse: () => CartItem.empty(),
    );
    if (item.id == 0) {
      return;
    }
    if (quantity <= 0) {
      cartItems.removeWhere((it) => it.id == id);
    } else {
      item.quantity = quantity;
    }
    notifyListeners();
  }

  void deleteCartItem(int id) {
    cartItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void checkout(
    String name,
    String phone,
    String address,
    String paymentMethod,
  ) {
    notifications.insert(
      0,
      NotificationItem(
        title: 'Đơn hàng đã đặt thành công',
        content:
            'Cảm ơn $name, đơn hàng của bạn ($paymentMethod) với tổng trị giá đã được xử lý và sẽ giao tới: $address',
        timeAgo: 'Vừa xong',
        category: 'DELIVERY',
        isRead: false,
      ),
    );
    cartItems.clear();
    notifyListeners();
  }

  void markAllNotificationsRead() {
    for (var item in notifications) {
      item.isRead = true;
    }
    notifyListeners();
  }

  void setSelectedTabIndex(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> sendChatMessage(String message) async {
    if (message.trim().isEmpty) {
      return;
    }
    chatMessages.add(ChatMessage(message: message.trim(), isUser: true));
    isBotTyping = true;
    notifyListeners();

    final history = List<ChatMessage>.from(chatMessages);
    final response = await GeminiClient.getChatBotResponse(message, history);
    chatMessages.add(ChatMessage(message: response, isUser: false));
    isBotTyping = false;
    notifyListeners();
  }

  void clearChat() {
    chatMessages.clear();
    chatMessages.add(
      ChatMessage(
        message:
            'Chào mừng bạn quay lại với SportZone hỗ trợ trực tuyến! Tôi là trợ lý ảo, tôi có thể tư vấn mẫu giày Nike Dunk Low, Pegasus hay Air Zoom cho bạn hôm nay?',
        isUser: false,
      ),
    );
    notifyListeners();
  }
}

