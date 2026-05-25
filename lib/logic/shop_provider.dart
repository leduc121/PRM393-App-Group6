import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import '../data/shop_repository.dart';
import '../data/gemini_service.dart';

enum ActiveScreen {
  login,
  home,
  productDetail,
  cart,
  notifications,
  map,
  chat,
}

class ShopState {
  final ActiveScreen currentScreen;
  final int? selectedProductId; // Track ProductDetail screen
  final String currentUserEmail;
  final String currentUserName;
  final bool isLoggedIn;
  
  final String searchKeyword;
  final String selectedCategory;

  final String promoCode;
  final bool isPromoApplied;
  final String promoMessage;

  final String checkoutAddress;
  final String checkoutPaymentMethod;

  final bool isChatLoading;
  final String chatInput;

  ShopState({
    this.currentScreen = ActiveScreen.login,
    this.selectedProductId,
    this.currentUserEmail = "",
    this.currentUserName = "",
    this.isLoggedIn = false,
    this.searchKeyword = "",
    this.selectedCategory = "Tất cả",
    this.promoCode = "",
    this.isPromoApplied = false,
    this.promoMessage = "",
    this.checkoutAddress = "",
    this.checkoutPaymentMethod = "Thanh toán tiền mặt khi giao (COD)",
    this.isChatLoading = false,
    this.chatInput = "",
  });

  ShopState copyWith({
    ActiveScreen? currentScreen,
    int? Function()? selectedProductId,
    String? currentUserEmail,
    String? currentUserName,
    bool? isLoggedIn,
    String? searchKeyword,
    String? selectedCategory,
    String? promoCode,
    bool? isPromoApplied,
    String? promoMessage,
    String? checkoutAddress,
    String? checkoutPaymentMethod,
    bool? isChatLoading,
    String? chatInput,
  }) {
    return ShopState(
      currentScreen: currentScreen ?? this.currentScreen,
      selectedProductId: selectedProductId != null ? selectedProductId() : this.selectedProductId,
      currentUserEmail: currentUserEmail ?? this.currentUserEmail,
      currentUserName: currentUserName ?? this.currentUserName,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      promoCode: promoCode ?? this.promoCode,
      isPromoApplied: isPromoApplied ?? this.isPromoApplied,
      promoMessage: promoMessage ?? this.promoMessage,
      checkoutAddress: checkoutAddress ?? this.checkoutAddress,
      checkoutPaymentMethod: checkoutPaymentMethod ?? this.checkoutPaymentMethod,
      isChatLoading: isChatLoading ?? this.isChatLoading,
      chatInput: chatInput ?? this.chatInput,
    );
  }
}

// Database and Repository providers
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final repositoryProvider = Provider<ShopRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ShopRepository(db);
});

// Reacting Stream providers
final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.watchAllProducts();
});

final cartItemsStreamProvider = StreamProvider<List<CartItem>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.watchCartItems();
});

final ordersStreamProvider = StreamProvider<List<Order>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.watchAllOrders();
});

final chatMessagesStreamProvider = StreamProvider<List<ChatMessage>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.watchChatMessages();
});

final notificationsStreamProvider = StreamProvider<List<Notification>>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.watchAllNotifications();
});

final unreadNotificationsCountProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(repositoryProvider);
  return repo.watchAllNotifications().map((list) => list.where((item) => !item.isRead).length);
});

// Shop state provider
final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  return ShopNotifier(ref);
});

class ShopNotifier extends StateNotifier<ShopState> {
  final Ref ref;

  ShopNotifier(this.ref) : super(ShopState()) {
    _init();
  }

  ShopRepository get repository => ref.read(repositoryProvider);

  Future<void> _init() async {
    await repository.seedDatabaseIfEmpty();
  }

  void navigateTo(ActiveScreen screen, {int? productId}) {
    state = state.copyWith(
      currentScreen: screen,
      selectedProductId: () => productId,
    );
  }

  void loginUser(String email, String name) {
    final userName = name.trim().isEmpty ? "Khách hàng" : name;
    state = state.copyWith(
      currentUserEmail: email,
      currentUserName: userName,
      isLoggedIn: true,
      currentScreen: ActiveScreen.home,
    );

    repository.addNotification(
      "Đăng nhập thành công! ⚡",
      "Chào mừng $userName đến với AeroSport. Hành trình tập luyện bứt phá của bạn đã sẵn sàng!",
    );
  }

  void loginAsGuest() {
    state = state.copyWith(
      currentUserEmail: "guest@aerosport.vn",
      currentUserName: "Hội viên Aero",
      isLoggedIn: true,
      currentScreen: ActiveScreen.home,
    );

    repository.addNotification(
      "Đăng nhập chế độ khách 🎫",
      "Chào mừng Hội viên mới bước vào thế giới thể dục thể thao AeroSport!",
    );
  }

  void logoutUser() {
    state = state.copyWith(
      currentUserEmail: "",
      currentUserName: "",
      isLoggedIn: false,
      currentScreen: ActiveScreen.login,
    );
  }

  void updateSearchKeyword(String value) {
    state = state.copyWith(searchKeyword: value);
  }

  void updateCategory(String value) {
    state = state.copyWith(selectedCategory: value);
  }

  void applyPromo(String code) {
    final uppercaseCode = code.toUpperCase().trim();
    if (uppercaseCode == "AEROFIT10") {
      state = state.copyWith(
        isPromoApplied: true,
        promoMessage: "Chúc mừng! Đã áp dụng mã giảm giá 10% (AEROFIT10)",
        promoCode: uppercaseCode,
      );
      repository.addNotification(
        "Voucher ưu đãi ⚡",
        "Bạn vừa kích hoạt quà tặng giảm giá 10% cực sốc từ AeroSport!",
      );
    } else {
      state = state.copyWith(
        isPromoApplied: false,
        promoMessage: "Mã CODE của bạn chưa chính xác!",
      );
    }
  }

  void removePromo() {
    state = state.copyWith(
      isPromoApplied: false,
      promoMessage: "",
      promoCode: "",
    );
  }

  Future<void> addToCart(int productId, {int quantity = 1}) async {
    final cartItems = ref.read(cartItemsStreamProvider).value ?? [];
    final existing = cartItems.where((item) => item.productId == productId).firstOrNull;
    final newQuantity = (existing?.quantity ?? 0) + quantity;
    await repository.insertCartItem(productId, newQuantity);
  }

  Future<void> updateCartQuantity(int productId, int quantity) async {
    await repository.insertCartItem(productId, quantity);
  }

  Future<void> removeFromCart(int productId) async {
    await repository.deleteCartItem(productId);
  }

  void updateCheckoutAddress(String value) {
    state = state.copyWith(checkoutAddress: value);
  }

  void updateCheckoutPaymentMethod(String value) {
    state = state.copyWith(checkoutPaymentMethod: value);
  }

  Future<void> placeOrder({
    required double total,
    required String itemDetails,
    required VoidCallback onOrderCompleted,
  }) async {
    if (state.checkoutAddress.trim().isEmpty) {
      await repository.addNotification(
        "Lỗi địa chỉ giao ❌",
        "Vui lòng hoàn thành địa chỉ giao hàng trước khi tiếp tục đặt mua.",
      );
      return;
    }

    await repository.placeOrder(
      amount: total,
      itemDetails: itemDetails,
      address: state.checkoutAddress,
      payment: state.checkoutPaymentMethod,
    );

    await repository.clearCart();

    // Reset checkout inputs
    state = state.copyWith(
      checkoutAddress: "",
      isPromoApplied: false,
      promoMessage: "",
      promoCode: "",
    );

    onOrderCompleted();
  }

  void updateChatInput(String value) {
    state = state.copyWith(chatInput: value);
  }

  Future<void> sendChatMessage(String apiKey) async {
    final text = state.chatInput.trim();
    if (text.isEmpty) return;

    state = state.copyWith(chatInput: "", isChatLoading: true);

    // Save user message
    await repository.postChatMessage("user", text);

    // Get chat history
    final history = ref.read(chatMessagesStreamProvider).value ?? [];

    // Get response from Gemini
    final responseText = await GeminiService.getChatResponse(text, history, apiKey);

    // Save AI message
    await repository.postChatMessage("shop", responseText);

    state = state.copyWith(isChatLoading: false);
  }

  Future<void> clearChatHistory() async {
    await repository.clearChat();
  }

  Future<void> markNotificationAsRead(int id) async {
    await repository.markNotificationAsRead(id);
  }

  Future<void> addNotification(String title, String message) async {
    await repository.addNotification(title, message);
  }
}
