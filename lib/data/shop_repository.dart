import 'package:drift/drift.dart';
import 'database.dart';

class ShopRepository {
  final AppDatabase db;

  ShopRepository(this.db);

  Stream<List<Product>> watchAllProducts() => db.select(db.products).watch();
  Stream<List<CartItem>> watchCartItems() => db.select(db.cartItems).watch();
  
  Stream<List<Order>> watchAllOrders() {
    return (db.select(db.orders)
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<ChatMessage>> watchChatMessages() {
    return (db.select(db.chatMessages)
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.asc)]))
        .watch();
  }

  Stream<List<Notification>> watchAllNotifications() {
    return (db.select(db.notifications)
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<void> seedDatabaseIfEmpty() async {
    final products = await db.select(db.products).get();
    if (products.isEmpty) {
      final initialProducts = [
        Product(
          id: 1,
          name: "Aero Pro Whey Isolate",
          category: "Nutrition",
          price: 49.99,
          originalPrice: 59.99,
          rating: 4.8,
          reviewCount: 128,
          description: "Ultra-pure whey isolate for muscle repair. Grass-fed, sweetened with stevia.",
          specs: "Flavors: Double Dark Chocolate, Vanilla Bean\nWeight: 2.2 lbs\nProtein: 26g per scoop\nCarbs: 0g, Fats: 0.5g",
          imageName: "fit_nutrition_whey",
          tag: "15% OFF",
          stock: 15,
        ),
        Product(
          id: 2,
          name: "Pre-Workout Ignition",
          category: "Nutrition",
          price: 29.99,
          originalPrice: 34.99,
          rating: 4.6,
          reviewCount: 95,
          description: "Clean energy booster with natural beetroot extract, caffeine, and L-Theanine for focus.",
          specs: "Flavor: Cosmic Blue Raspberry\nServings: 30\nCaffeine: 150mg\nBeta-Alanine: 3.2g",
          imageName: "fit_nutrition_prework",
          tag: "Trending",
          stock: 8,
        ),
        Product(
          id: 3,
          name: "AeroGrip Performance Gloves",
          category: "Gym Gear",
          price: 19.99,
          originalPrice: 19.99,
          rating: 4.5,
          reviewCount: 41,
          description: "Breathable gloves with palm gel pads for weight lifting.",
          specs: "Sizes: S, M, L\nMaterial: Nylon Mesh & Palm Rubber\nWashable: Yes (Machine safe)",
          imageName: "fit_gear_gloves",
          tag: "",
          stock: 22,
        ),
        Product(
          id: 4,
          name: "Pro Adjustable Kettlebell",
          category: "Gym Gear",
          price: 89.99,
          originalPrice: 99.99,
          rating: 4.9,
          reviewCount: 74,
          description: "Cast iron kettlebell with wide handle, adjustable weights.",
          specs: "Weight: 10 lbs to 40 lbs adjustable\nMaterial: High Gloss Cast Iron\nBase: Anti-scratch rubber pad",
          imageName: "fit_gear_kettle",
          tag: "Premium Quality",
          stock: 5,
        ),
        Product(
          id: 5,
          name: "Therma-Cool Run Tee",
          category: "Apparel",
          price: 24.99,
          originalPrice: 29.99,
          rating: 4.7,
          reviewCount: 112,
          description: "Moisture-wicking active tee built to keep you dry and comfortable.",
          specs: "Sizes: S, M, L, XL\nColors: Crimson Red, Aero Teal\nMaterial: 100% Recycled Poly-yarn",
          imageName: "fit_apparel_tee",
          tag: "New Arrival",
          stock: 30,
        ),
        Product(
          id: 6,
          name: "Carbon-Flex Training Shorts",
          category: "Apparel",
          price: 34.99,
          originalPrice: 34.99,
          rating: 4.6,
          reviewCount: 83,
          description: "Dual-layer athletic shorts featuring compression liner and pocket.",
          specs: "Sizes: M, L, XL\nInseam: 7 in inner / 5 in outer\nColors: Carbon Slate, Aqua Teal",
          imageName: "fit_apparel_shorts",
          tag: "Bestseller",
          stock: 18,
        ),
      ];

      await db.batch((batch) {
        batch.insertAll(db.products, initialProducts);
      });

      // Seed initial notification
      await db.into(db.notifications).insert(
            NotificationsCompanion.insert(
              title: "Chào mừng tới AeroSport! 🎉",
              message: "Cửa hàng thể thao & dinh dưỡng nội địa lớn nhất khu vực. Nhận voucher giảm giá 10% cho đơn hàng đầu tiên của bạn bằng cách hỏi AI Assistant của Shop!",
              timestamp: DateTime.now().millisecondsSinceEpoch - 3600000,
              isRead: const Value(false),
            ),
          );

      // Seed initial greeting message
      await db.into(db.chatMessages).insert(
            ChatMessagesCompanion.insert(
              sender: "shop",
              message: "Xin chào! Mình là Trợ lý AI đặc biệt của AeroSport Shop. Rất vui được hỗ trợ bạn tìm đồ tập, Whey, hay đặt đơn hàng giao ngay hôm nay. Bạn cần tìm gì ạ? 😊",
              timestamp: DateTime.now().millisecondsSinceEpoch - 500000,
            ),
          );
    }
  }

  Future<Product?> getProductById(int id) async {
    return await (db.select(db.products)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertCartItem(int productId, int quantity) async {
    if (quantity <= 0) {
      await (db.delete(db.cartItems)..where((t) => t.productId.equals(productId))).go();
    } else {
      await db.into(db.cartItems).insertOnConflictUpdate(
            CartItem(productId: productId, quantity: quantity),
          );
    }
  }

  Future<void> deleteCartItem(int productId) async {
    await (db.delete(db.cartItems)..where((t) => t.productId.equals(productId))).go();
  }

  Future<void> clearCart() async {
    await db.delete(db.cartItems).go();
  }

  Future<int> placeOrder({
    required double amount,
    required String itemDetails,
    required String address,
    required String payment,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Insert order record
    await db.into(db.orders).insert(
          OrdersCompanion.insert(
            timestamp: timestamp,
            totalAmount: amount,
            itemDetails: itemDetails,
            status: "Processing",
            deliveryAddress: address,
            paymentMethod: payment,
          ),
        );

    // Add a notification about order success
    final amountFormatted = amount.toStringAsFixed(2);
    await db.into(db.notifications).insert(
          NotificationsCompanion.insert(
            title: "Đặt hàng thành công! 🛒",
            message: "Đơn hàng trị giá \$$amountFormatted đã được thiết lập thành công. Phương thức: $payment. Nhân viên đang chuẩn bị giao hàng cho bạn.",
            timestamp: timestamp,
          ),
        );

    return 1;
  }

  Future<void> postChatMessage(String sender, String text) async {
    await db.into(db.chatMessages).insert(
          ChatMessagesCompanion.insert(
            sender: sender,
            message: text,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> clearChat() async {
    await db.delete(db.chatMessages).go();
    // Re-seed greeting
    await db.into(db.chatMessages).insert(
          ChatMessagesCompanion.insert(
            sender: "shop",
            message: "Xin chào! Mình là Trợ lý AI đặc biệt của AeroSport Shop. Rất vui được hỗ trợ bạn tìm đồ tập, Whey, hay đặt đơn hàng giao ngay hôm nay. Bạn cần tìm gì ạ? 😊",
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> addNotification(String title, String message) async {
    await db.into(db.notifications).insert(
          NotificationsCompanion.insert(
            title: title,
            message: message,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> markNotificationAsRead(int id) async {
    await (db.update(db.notifications)..where((t) => t.id.equals(id))).write(
      const NotificationsCompanion(isRead: Value(true)),
    );
  }
}
