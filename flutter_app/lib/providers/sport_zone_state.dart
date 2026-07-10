import 'package:flutter/material.dart';
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
  String? searchQuery;

  final List<CartItem> cartItems = [];
  final List<NotificationItem> notifications = [];
  final List<Voucher> availableVouchers = [];
  DateTime? _cartUpdatedAt;
  bool _cartReminderDismissed = false;
  bool _cartReminderRead = false;

  final List<ChatMessage> chatMessages = [
    ChatMessage(
      message:
          'Chào bạn, nhân viên sẽ hỗ trợ bạn ngay trong giây lát. Vui lòng cho biết size chân thông thường của bạn nhé!',
      isUser: false,
    ),
  ];

  List<NotificationItem> get visibleNotifications {
    final items = [...notifications];
    if (cartItems.isNotEmpty && !_cartReminderDismissed) {
      items.insert(
        0,
        NotificationItem.cartReminder(
          itemCount: cartItems.fold<int>(0, (sum, item) => sum + item.quantity),
          createdAt: _cartUpdatedAt,
          isRead: _cartReminderRead,
        ),
      );
    }
    items.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.now();
      final bDate = b.createdAt ?? DateTime.now();
      return bDate.compareTo(aDate);
    });
    return items;
  }

  // ─── Auth Methods (API) ───

  /// Try auto-login using saved token
  Future<bool> tryAutoLogin() async {
    final token = await ApiService.getToken();
    if (token == null) return false;

    final result = await ApiService.getMe();
    if (result.isSuccess && result.data != null) {
      currentUser = User.fromJson(result.data as Map<String, dynamic>);
      await fetchCart();
      await fetchNotifications();
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
      await fetchCart();
      await fetchNotifications();
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
    notifications.clear();
    _cartReminderDismissed = false;
    _cartReminderRead = false;
    selectedTabIndex = 0;
    notifyListeners();
  }

  Future<String?> updateProfileAsync({
    required String fullName,
    required String phone,
    String? avatarUrl,
  }) async {
    final user = currentUser;
    if (user == null) return 'Vui lòng đăng nhập lại';

    final result = await ApiService.updateUserProfile(user.uid, {
      'fullName': fullName,
      'phone': phone,
      'avatarUrl': avatarUrl,
    });

    if (!result.isSuccess) {
      return result.errorMessage ?? 'Cập nhật profile thất bại';
    }

    currentUser = User.fromJson(result.data as Map<String, dynamic>);
    notifyListeners();
    return null;
  }

  Future<String?> verifyOtpAsync(String email, String otp) async {
    isLoadingAuth = true;
    authError = null;
    notifyListeners();

    final result = await ApiService.verifyOtp(email: email, otp: otp);

    isLoadingAuth = false;

    if (result.isSuccess) {
      final data = result.data as Map<String, dynamic>;
      if (data['user'] != null) {
        currentUser = User.fromJson(data['user'] as Map<String, dynamic>);
      }
      await fetchCart();
      await fetchNotifications();
      notifyListeners();
      return null; // success
    } else {
      notifyListeners();
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

  Future<void> fetchProducts({
    String? categoryId,
    String? brandId,
    int? minPrice,
    int? maxPrice,
    String? gender,
    String? size,
    String? search,
  }) async {
    isLoadingProducts = true;
    notifyListeners();

    if (search != null) {
      searchQuery = search.isEmpty ? null : search;
    }

    final result = await ApiService.getProducts(
      limit: 50,
      categoryId: categoryId,
      brandId: brandId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      gender: gender,
      size: size,
      search: searchQuery,
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
    fetchProducts(
      categoryId: categoryId,
      brandId: selectedBrandId,
      minPrice: filterMinPrice,
      maxPrice: filterMaxPrice,
      gender: filterGender,
      size: filterSize,
    );
  }

  void selectBrand(String value, {String? brandId}) {
    selectedBrand = value;
    selectedBrandId = brandId;
    fetchProducts(
      categoryId: selectedCategoryId,
      brandId: brandId,
      minPrice: filterMinPrice,
      maxPrice: filterMaxPrice,
      gender: filterGender,
      size: filterSize,
    );
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

  void _updateLocalCart(Map<String, dynamic> cartData) {
    final itemsList = cartData['items'] as List<dynamic>? ?? [];
    final hadItems = cartItems.isNotEmpty;
    cartItems.clear();
    cartItems.addAll(
      itemsList.map((json) => CartItem.fromJson(json as Map<String, dynamic>)),
    );
    if (cartItems.isNotEmpty) {
      _cartUpdatedAt = DateTime.now();
      if (!hadItems) {
        _cartReminderDismissed = false;
        _cartReminderRead = false;
      }
    } else {
      _cartUpdatedAt = null;
      _cartReminderDismissed = false;
      _cartReminderRead = false;
    }
    notifyListeners();
  }

  Future<void> fetchCart() async {
    final result = await ApiService.getCart();
    if (result.isSuccess && result.data != null) {
      _updateLocalCart(result.data as Map<String, dynamic>);
    }
  }

  Future<String?> addToCart(
    Product product, {
    String? variantId,
    String? size,
    String? color,
    int quantity = 1,
  }) async {
    try {
      String? targetVariantId = variantId;

      if (targetVariantId == null) {
        final detailResult = await ApiService.getProductDetail(product.id);
        if (!detailResult.isSuccess) {
          return detailResult.errorMessage ??
              'Không thể tải thông tin sản phẩm';
        }

        final List vList = detailResult.data['variants'] ?? [];
        final variants = vList.map((v) => ProductVariant.fromJson(v)).toList();
        if (variants.isEmpty) {
          return 'Sản phẩm hiện tại không có sẵn kích cỡ/màu sắc.';
        }

        ProductVariant matched;
        if (size != null && color != null) {
          matched = variants.firstWhere(
            (v) => v.size == size && v.colorName == color,
            orElse: () => variants.first,
          );
        } else {
          matched = variants.first;
        }
        targetVariantId = matched.id;
      }

      final cartResult = await ApiService.addToCart(
        variantId: targetVariantId,
        quantity: quantity,
      );

      if (cartResult.isSuccess) {
        _updateLocalCart(cartResult.data);
        return null;
      } else {
        return cartResult.errorMessage ?? 'Không thể thêm vào giỏ hàng';
      }
    } catch (e) {
      return 'Lỗi: $e';
    }
  }

  Future<String?> updateCartItemQuantity(String itemId, int quantity) async {
    try {
      if (quantity <= 0) {
        return deleteCartItem(itemId);
      }
      final result = await ApiService.updateCartItem(
        itemId: itemId,
        quantity: quantity,
      );
      if (result.isSuccess) {
        _updateLocalCart(result.data);
        return null;
      } else {
        return result.errorMessage ?? 'Cập nhật giỏ hàng thất bại';
      }
    } catch (e) {
      return 'Lỗi: $e';
    }
  }

  Future<String?> deleteCartItem(String itemId) async {
    try {
      final result = await ApiService.deleteCartItem(itemId: itemId);
      if (result.isSuccess) {
        _updateLocalCart(result.data);
        return null;
      } else {
        return result.errorMessage ?? 'Xóa mặt hàng thất bại';
      }
    } catch (e) {
      return 'Lỗi: $e';
    }
  }

  Future<ApiResult> checkout({
    required String recipientName,
    required String phone,
    required String street,
    required String paymentMethod,
    String? note,
    String? voucherId,
  }) async {
    if (currentUser == null) {
      return ApiResult.error('Vui lòng đăng nhập để thanh toán');
    }

    try {
      // 1. Get user's addresses
      final addrResult = await ApiService.getAddresses(currentUser!.uid);
      String? addressId;

      if (addrResult.isSuccess && addrResult.data is List) {
        final List list = addrResult.data;
        // Check if there is an exact match
        for (var addr in list) {
          if (addr['recipientName'] == recipientName &&
              addr['phone'] == phone &&
              addr['street'] == street) {
            addressId = addr['addressId']?.toString();
            break;
          }
        }
      }

      // 2. If no matching address, create one
      if (addressId == null) {
        final createAddrResult = await ApiService.createAddress(
          uid: currentUser!.uid,
          recipientName: recipientName,
          phone: phone,
          street: street,
          district: 'Quận 1', // fallback since simple address text field
          city: 'TP. Hồ Chí Minh',
          isDefault: true,
        );
        if (!createAddrResult.isSuccess) {
          return ApiResult.error(
            createAddrResult.errorMessage ?? 'Không thể tạo địa chỉ giao hàng',
          );
        }
        addressId = createAddrResult.data['addressId']?.toString();
      }

      if (addressId == null) {
        return ApiResult.error('Lỗi khởi tạo địa chỉ giao hàng');
      }

      // 3. Create order on backend
      final orderResult = await ApiService.createOrder(
        addressId: addressId,
        paymentMethod: paymentMethod,
        note: note,
        voucherId: voucherId,
      );

      if (orderResult.isSuccess) {
        // Clear local cart items because the backend has cleared it
        cartItems.clear();
        await fetchNotifications();
        // Refresh user data to get updated tier/totalSpent
        final meResult = await ApiService.getMe();
        if (meResult.isSuccess && meResult.data != null) {
          currentUser = User.fromJson(meResult.data as Map<String, dynamic>);
        }

        notifyListeners();
        return ApiResult.success(orderResult.data);
      } else {
        return ApiResult.error(orderResult.errorMessage ?? 'Đặt hàng thất bại');
      }
    } catch (e) {
      return ApiResult.error('Lỗi thanh toán: $e');
    }
  }

  Future<void> fetchNotifications() async {
    final result = await ApiService.getNotifications();
    if (result.isSuccess && result.data is List) {
      notifications
        ..clear()
        ..addAll(
          (result.data as List).whereType<Map<String, dynamic>>().map(
            NotificationItem.fromJson,
          ),
        );
      notifyListeners();
    }
  }

  Future<void> fetchMyVouchers() async {
    final result = await ApiService.getMyVouchers();
    if (result.isSuccess && result.data is List) {
      availableVouchers
        ..clear()
        ..addAll(
          (result.data as List).whereType<Map<String, dynamic>>().map(
            (json) => Voucher.fromJson(json),
          ),
        );
      notifyListeners();
    }
  }

  void markAllNotificationsRead() {
    ApiService.markAllNotificationsRead();
    for (var item in notifications) {
      item.isRead = true;
    }
    _cartReminderRead = true;
    notifyListeners();
  }

  void clearAllNotifications() {
    ApiService.clearNotifications();
    notifications.clear();
    _cartReminderDismissed = true;
    _cartReminderRead = true;
    notifyListeners();
  }

  void deleteNotification(NotificationItem item) {
    if (item.isCartReminder) {
      _cartReminderDismissed = true;
      _cartReminderRead = true;
    } else {
      notifications.removeWhere((notification) => notification.id == item.id);
      final id = item.id;
      if (id != null && id.isNotEmpty) {
        ApiService.deleteNotification(id);
      }
    }
    notifyListeners();
  }

  void setSelectedTabIndex(int index) {
    selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> fetchMessages() async {
    final result = await ApiService.getMessages();
    if (result.isSuccess) {
      final raw = result.data;
      if (raw is List) {
        chatMessages.clear();
        chatMessages.addAll(
          raw.whereType<Map<String, dynamic>>().map(
            (json) => ChatMessage.fromJson(json, isCurrentUserAdmin: false),
          ),
        );
        notifyListeners();
      }
    }
  }

  Future<void> sendChatMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add locally for instant UI update
    chatMessages.add(
      ChatMessage(message: message.trim(), isUser: true, isRead: false),
    );
    notifyListeners();

    final result = await ApiService.sendMessage(message);
    if (result.isSuccess) {
      await fetchMessages();
    }
  }

  void clearChat() {
    chatMessages.clear();
    notifyListeners();
  }
}
