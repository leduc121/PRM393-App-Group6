import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const SportZoneApp());
}

class SportZoneApp extends StatelessWidget {
  const SportZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SportZoneState(),
      child: MaterialApp(
        title: 'SportZone',
        debugShowCheckedModeBanner: false,
        theme: SportZoneTheme.lightTheme,
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/main': (_) => const MainScreen(),
          '/checkout': (_) => const CheckoutScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/product') {
            final product = settings.arguments as Product;
            return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            );
          }
          return null;
        },
      ),
    );
  }
}

class SportZoneTheme {
  static const primary = Color(0xFF000000);
  static const onPrimary = Color(0xFFFFFFFF);
  static const background = Color(0xFFF9F9F9);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF5F5F5);
  static const surfaceContainerLow = Color(0xFFF3F3F4);
  static const secondary = Color(0xFF5D5F5F);
  static const electricLime = Color(0xFFD5FF44);
  static const borderSubtle = Color(0xFFE0E0E0);
  static const error = Color(0xFFBA1A1A);

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: onPrimary,
      surface: surface,
      onSurface: Color(0xFF1A1C1C),
      surfaceContainerHighest: surfaceVariant,
      onSecondary: onPrimary,
      secondary: secondary,
      error: error,
      onError: onPrimary,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.w900, fontSize: 44),
      headlineLarge: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
      labelLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      labelSmall: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

class SportZoneState extends ChangeNotifier {
  User? currentUser;
  String selectedCategory = 'Tất cả';
  bool isBotTyping = false;
  int selectedTabIndex = 0;

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

  void selectCategory(String value) {
    selectedCategory = value;
    notifyListeners();
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

  bool login(String username, String password) {
    if (username.isNotEmpty && password.length >= 4) {
      currentUser = User(
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
      currentUser = User(name: name, email: email, phone: phone);
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }
}

class Product {
  final String id;
  final String brand;
  final String name;
  final int price;
  final int? originalPrice;
  final String? discount;
  final String imageUrl;
  final String category;
  final String description;

  Product({
    required this.id,
    required this.brand,
    required this.name,
    required this.price,
    this.originalPrice,
    this.discount,
    required this.imageUrl,
    required this.category,
    required this.description,
  });
}

class CartItem {
  final int id;
  final String productId;
  final String name;
  final int price;
  final String imageUrl;
  int quantity;
  final String size;
  final String color;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.size,
    required this.color,
  });

  CartItem.empty()
    : id = 0,
      productId = '',
      name = '',
      price = 0,
      imageUrl = '',
      quantity = 0,
      size = '',
      color = '';
}

class NotificationItem {
  final String title;
  final String content;
  final String timeAgo;
  final String category;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.content,
    required this.timeAgo,
    required this.category,
    this.isRead = false,
  });
}

class ChatMessage {
  final String message;
  final bool isUser;

  ChatMessage({required this.message, required this.isUser});
}

class GeminiClient {
  static const _modelName = 'gemini-3.5-flash';
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  static Future<String> getChatBotResponse(
    String userPrompt,
    List<ChatMessage> historyPrompts,
  ) async {
    if (_apiKey.isEmpty || _apiKey == 'MY_GEMINI_API_KEY') {
      await Future.delayed(const Duration(milliseconds: 700));
      return _fallbackReply(userPrompt);
    }

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 60);

    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_modelName:generateContent?key=$_apiKey',
      );
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(_requestBody(userPrompt, historyPrompts)));

      final response = await request.close().timeout(
        const Duration(seconds: 60),
      );
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return 'Tôi gặp chút gián đoạn kết nối. Bạn vui lòng hỏi lại để SportZone Bot hỗ trợ nhé!';
      }

      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final candidates = decoded['candidates'] as List<dynamic>?;
      final content = candidates?.isNotEmpty == true
          ? candidates!.first['content'] as Map<String, dynamic>?
          : null;
      final parts = content?['parts'] as List<dynamic>?;
      final text = parts?.isNotEmpty == true
          ? parts!.first['text'] as String?
          : null;

      return text?.trim().isNotEmpty == true
          ? text!.trim()
          : 'Hệ thống hỗ trợ bận một chút, vui lòng nhắn lại giúp tôi nhé!';
    } catch (_) {
      return 'Chào bạn! Có vẻ mạng đang trễ. Về size giày Nike Dunk Low, form này ôm nhẹ nên nếu chân dày, bạn hãy cân nhắc tăng thêm 0.5 hoặc 1 size nhé.';
    } finally {
      client.close(force: true);
    }
  }

  static Map<String, dynamic> _requestBody(
    String userPrompt,
    List<ChatMessage> historyPrompts,
  ) {
    final contents = historyPrompts
        .map(
          (message) => {
            'role': message.isUser ? 'user' : 'model',
            'parts': [
              {'text': message.message},
            ],
          },
        )
        .toList();

    contents.add({
      'role': 'user',
      'parts': [
        {'text': userPrompt},
      ],
    });

    return {
      'contents': contents,
      'systemInstruction': {
        'parts': [
          {
            'text':
                'You are SportZone Bot, an expert AI assistant for SportZone, a premium sports fashion and sneaker retailer. '
                'Respond in Vietnamese. Be concise, helpful, professional, sporty, and use a friendly retail advisor tone. '
                'You know these SportZone products: Nike Air Zoom giá 3.500.000đ, Pegasus 40 giá 2.800.000đ, '
                'Nike Dunk Low Retro giá 2.990.000đ, Adidas Jersey 23/24 giá 1.950.000đ, Giày Nitro Elite v2 giá 3.120.000đ, '
                'Quần Short Chạy Bộ Pro giá 850.000đ. Recommend sizes: 38 is 23.5cm, 39 is 24cm, 40 is 25cm, '
                '41 is 26cm, 42 is 27cm. Encourage purchasing from SportZone.',
          },
        ],
      },
    };
  }

  static String _fallbackReply(String userMessage) {
    final lower = userMessage.toLowerCase();
    if (lower.contains('nike') || lower.contains('size')) {
      return 'Với Nike Dunk Low, bạn nên tăng 0.5 đến 1 size nếu chân dày. Ví dụ size 40 hoặc 41 nếu chân bạn dài 25cm.';
    }
    if (lower.contains('adidas')) {
      return 'Áo đấu sân nhà 23/24 rất thoáng khí và phù hợp cho hoạt động ngoài trời, bạn có thể chọn size vừa với vòng ngực.';
    }
    return 'Chào bạn! SportZone gợi ý bạn chọn sản phẩm phù hợp với phong cách tập luyện và kích cỡ hiện tại của bạn. Bạn cần tư vấn sản phẩm nào?';
  }
}

class User {
  final String name;
  final String email;
  final String phone;

  User({required this.name, required this.email, required this.phone});
}

final productList = <Product>[
  Product(
    id: 'pegasus_40',
    brand: 'NIKE',
    name: 'Giày Chạy Bộ Pegasus 40',
    price: 2800000,
    originalPrice: 3200000,
    discount: '-15%',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAPgZ35z3CkEwvbqr8k-JquljTF6IpGzOVENVsBz2K8tZ-B8ofcobg7F_hh14anJPHDkt3OWD5MosD_hXAqHeSaIkzJABizi6_KrbJnTjLkWTW4fw6IzNF1MkCurRALk0I4R_lTZ7AJualyOuLk6iUV152L7cSCtvzknNTWb28ebTMOODtIqhTMhm_MrmXfMVJu_-pOCD8QN5c2dyD3uSf6OZbWPVb2SXgbZmI-jmRNys_iTW_Kmkce-mCoTP52n8mc15IBmneoiiw',
    category: 'Giày',
    description:
        'Dòng giày chạy huyền thoại thế hệ thứ 40 từ Nike. Trực quan cấu trúc đệm Air Zoom đàn hồi, phân bố lực cực tốt giúp tối ưu hóa hiệu suất chạy bộ hàng ngày của bạn.',
  ),
  Product(
    id: 'adidas_jersey',
    brand: 'ADIDAS',
    name: 'Áo Đấu Sân Nhà 23/24',
    price: 1950000,
    discount: 'NEW',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAiaFXI5Cxb_0GKnscXnYic8wbcSO0VG4wPll3F-gFMrCYYYP1Q2ldcvN17oRLM8eRafaOKa2uylBn9s7cP_JqG5gEGk2c7QS4mEPXgeax9ogtvIoGO9VzaZGYQMa3gs9ewxGVAbXtMTmwTvctbQXjC8U3SKIeC3EK184IUqx2mzYkH9v8ZYfGyb4kroPxGe-r2gOTaXFxTPms-ZHwFvRJ7j9NRrZudM34Be7jg7cw9t8rjl2WXpH2CiXnOilk6DlwuZT8Os7LO64E',
    category: 'Áo',
    description:
        'Áo đấu sân nhà chính thức mùa giải 23/24 với chất liệu poly cao cấp thoáng mát, thoát mồ hôi tối ưu Aeroready giúp giữ cơ thể luôn khô ráo.',
  ),
  Product(
    id: 'puma_nitro',
    brand: 'PUMA',
    name: 'Giày Nitro Elite v2',
    price: 3120000,
    originalPrice: 3900000,
    discount: '-20%',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuClw8SeBc7ybQWos4zhQhwpAHWCH6cH79uq51FeDAOWGacbU38SgXZx7GYzyAmZivittK9IXVwWUTlfVApz4jHMCbH00LmazEFqNZ-PAUpB7lFqCu3ZFLhcfeyl-vX1yzRtjfQWK-FvqX7PGvY50ask2GjwitTwZ5jhUVi-k300xIa1uwe3ftgq9yjmgZSROLU_h_dfL6IgSbriJ7ZfSyANa44VP9Nk-1ZvOjm1q0iu5RobJq8HySRqru_4rgcwujSeuN977TbbhP4',
    category: 'Giày',
    description:
        'Thiết kế tương lai với bọt Nitro Elite phản lực siêu nhẹ. Tấm carbon chạy dọc đế giày hỗ trợ định hướng sải chân lực đẩy mạnh mẽ hơn.',
  ),
  Product(
    id: 'ua_shorts',
    brand: 'UNDER ARMOUR',
    name: 'Quần Short Chạy Bộ Pro',
    price: 850000,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCcDbqg7_acURvQe-3zwJXfHED3injZq8T6fYgwf_S23DqF2XbEpnvt7gm5vkaXj2HOyLUrZWjFwg5bz1z3zxzuQatiQmyT1lDKlYbEekm21dzMaxeiHXOnPlXD_x7rSBedhpwegWwFS2OYndPqbAdWWMOwehD99e69CqiTKnfA_W35qCLsetEVxBV8jU9NaBwr_u7mPjBZlSOpFVAKJD42nYisRlQzWoyxx9HrkBQQhBc6KCQTo726TWXv2J8XqKRRyGuZX1w9GJA',
    category: 'Quần',
    description:
        'Chất liệu siêu nhẹ co giãn 4 chiều mang đến dải chuyển động linh hoạt. Thắt lưng chun bản rộng siêu êm dễ điều chỉnh độ ôm.',
  ),
  Product(
    id: 'nike_air_zoom',
    brand: 'NIKE',
    name: 'Giày Chạy Bộ Nike Air Zoom',
    price: 3500000,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBiSz7-RpWpLuDEm1r56jSDqwAfxU_YumkO7qlQ8RBCnfhz84nCaf2i-ZsU53I7L7DSFkGcgRjaADsFmZFBSvch7CVsNKCZG_WgHqKryRZI866C0lSRqnvio04KC7x8N1Yz6NbaKR5h59y-UarxyUPt3CVM8ltOlWfm_pn_W6_Ssoeel4l3lIVvXePVg8kWxuDz1yn4e9i2bQoZYnFHnVoxR5NIln9RRePQjgooUmsCz8hgILRHZfVURCxguHWoRriOw-tD--hlsDg',
    category: 'Giày',
    description:
        'Được tối ưu hóa hoàn hảo với cấu trúc dệt Mesh tối tân và khối đệm Zoom Air phản hồi đỉnh cao, là lựa chọn số một cho tập luyện cường độ lớn.',
  ),
  Product(
    id: 'nike_air_max_270',
    brand: 'NIKE',
    name: 'Nike Air Max 270',
    price: 3450000,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDwjMhxELTWXCnRihkjjM1NTRAKElB0-G4V3tDZEOF5YDwxSrtqkQ2nM4TSjTUk1JVpWQw3lX1kpuhJQgnp-KhWsJ1BrcrJXO4YtMr7ZeiSnjUiKAkIa4tDAJ7OxElb8z45651q9j9Gsjk2_haEV8JOYKaDVD5wNr0ze6rtO0oHpayV5zARbohE0OVrLiz-kHqLGo76pPXQM_yhYNRQMpKTYsSrA5TU49vcFRBzYW29UyMFb61MMd8Z_E2WHfYZFitGa1jO4jrcvrY',
    category: 'Giày',
    description:
        'Phiên bản phong cách thời thượng với bong bóng đệm gót Air Max cao 270 độ siêu êm ái, mang lại chất thời trang đặc tả thương hiệu Nike.',
  ),
  Product(
    id: 'drifit_tee',
    brand: 'NIKE',
    name: 'Dri-FIT Adv Tee',
    price: 850000,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBNsAVhdXDzMjSFUsOGwXoVcurcTCD0DoHyZbUL4atVjxIu9WPq4fw8qTA1KhYJZDVpR-r9BNLAIJ10M8qYPC1sr08Ctlp20zLW1jTxzLA39li3SCSHagoCoWIW1Nh-pOMYM6FwqMdB6uwMD00PAQX2CZ2YouG3vayy507-5w7-VhEuJvbI9dz9OubjUTknV-mc5E6Dq7zG2elMYfSVDApuRhgYgUzmmYHOUe1rh9Sxuo6EuDCFu3Ns7irA7FU6IIvREXJg_Ll978Q',
    category: 'Áo',
    description:
        'Dòng áo dệt công nghệ thơi trang cao cấp chuyên sâu, sấy khô thông gió thoáng ở những vùng ra nhiều nhiệt chính trên cơ thể.',
  ),
  Product(
    id: 'nike_dunk_low',
    brand: 'NIKE',
    name: 'Nike Dunk Low Retro',
    price: 2990000,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAgjahdof8HWdDvif-Ci0fVoM1bIjYof_ZZb143kAaot8H7BWbItYPT90WOvFmendFdRAP0BVgx1JPj8P7TBxfYHzL8ugv7kzscsbVYXutG-KmGrs_bHPAVKbjr8sj9vRR3bJDpYa8wNlm0X-7Zj7J_cj6cveg3G0ARWgiLFPuo472HRl7lsdllLbaO0LUG5J2WjZJzTr76HQfvx6TTMYwMuBfRMynAdZHUaIA--7dnR3b3PE7xZ47HrtADNdDuoBmnuUiVmEURv8w',
    category: 'Giày',
    description:
        'Huyền thoại bóng rổ thập niên 80 chuyển mình thành biểu tượng văn hóa sát ván đường phố. Thiết kế chất da xịn bóng bẩy, thanh lịch.',
  ),
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 36),
              Text(
                'SPORTZONE',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: SportZoneTheme.primary,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Email hoặc Số điện thoại',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: SportZoneTheme.secondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  hintText: 'Nhập email hoặc số điện thoại',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mật khẩu',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: SportZoneTheme.secondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Nhập mật khẩu'),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Quên mật khẩu?',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    decoration: TextDecoration.underline,
                    color: SportZoneTheme.secondary,
                  ),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: SportZoneTheme.error),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SportZoneTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final username = usernameController.text.trim();
                    final password = passwordController.text;
                    if (state.login(username, password)) {
                      Navigator.pushReplacementNamed(context, '/main');
                    } else {
                      setState(() {
                        error = 'Vui lòng điền đầy đủ tài khoản & mật khẩu!';
                      });
                    }
                  },
                  child: Text(
                    'ĐĂNG NHẬP',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: SportZoneTheme.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Divider(color: SportZoneTheme.borderSubtle),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/register'),
                child: Text(
                  'Bạn chưa có tài khoản? Đăng ký ngay',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: SportZoneTheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  bool agreeTerms = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: SportZoneTheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'ĐĂNG KÝ',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(flex: 2),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.help_outline,
                      color: SportZoneTheme.primary,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'TẠO TÀI KHOẢN',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Trải nghiệm đỉnh cao cùng cộng đồng SportZone.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SportZoneTheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildField('Họ và tên', 'Nguyễn Văn A', nameController),
                      const SizedBox(height: 14),
                      _buildField(
                        'Email',
                        'example@sportzone.vn',
                        emailController,
                      ),
                      const SizedBox(height: 14),
                      _buildField(
                        'Số điện thoại',
                        '09xx xxx xxx',
                        phoneController,
                      ),
                      const SizedBox(height: 14),
                      _buildField(
                        'Mật khẩu',
                        '••••••••',
                        passwordController,
                        obscure: true,
                      ),
                      const SizedBox(height: 14),
                      _buildField(
                        'Xác nhận mật khẩu',
                        '••••••••',
                        confirmController,
                        obscure: true,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: agreeTerms,
                            onChanged: (value) =>
                                setState(() => agreeTerms = value ?? false),
                            activeColor: SportZoneTheme.primary,
                          ),
                          const Expanded(
                            child: Text(
                              'Tôi đồng ý với Điều khoản dịch vụ và Chính sách bảo mật của SPORTZONE.',
                            ),
                          ),
                        ],
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          error!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: SportZoneTheme.error),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SportZoneTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            final name = nameController.text.trim();
                            final email = emailController.text.trim();
                            final phone = phoneController.text.trim();
                            final pass = passwordController.text;
                            final confirm = confirmController.text;
                            if (name.isEmpty ||
                                email.isEmpty ||
                                phone.isEmpty ||
                                pass.isEmpty) {
                              setState(
                                () => error =
                                    'Vui lòng hoàn thành mọi vùng nhập của bạn!',
                              );
                            } else if (pass != confirm) {
                              setState(
                                () => error = 'Mật khẩu xác nhận không khớp!',
                              );
                            } else if (!agreeTerms) {
                              setState(
                                () => error =
                                    'Bạn phải đồng ý với các điều khoản của SPORTZONE!',
                              );
                            } else if (state.register(
                              name,
                              email,
                              phone,
                              pass,
                            )) {
                              Navigator.pushReplacementNamed(context, '/main');
                            }
                          },
                          child: Text(
                            'ĐĂNG KÝ',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: SportZoneTheme.onPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Divider(color: SportZoneTheme.borderSubtle),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'SPEED   POWER   ZONE',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: const Color.fromRGBO(93, 95, 95, 0.6),
                                fontWeight: FontWeight.w700,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String placeholder,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: SportZoneTheme.secondary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(hintText: placeholder),
        ),
      ],
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    final user = state.currentUser;
    return Scaffold(
      body: user == null
          ? const Center(child: Text('Vui lòng đăng nhập lại.'))
          : IndexedStack(
              index: state.selectedTabIndex,
              children: const [
                HomeScreen(),
                StoreLocationScreen(),
                ChatScreen(),
                AlertsScreen(),
                CartScreen(),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: state.selectedTabIndex,
        onTap: (index) => state.setSelectedTabIndex(index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: SportZoneTheme.electricLime,
        unselectedItemColor: Colors.white70,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_on),
            label: 'SHOP',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'MAP',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'CHAT'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (state.notifications.any((n) => !n.isRead))
                  const Positioned(right: 0, top: 0, child: BadgeBubble('!')),
              ],
            ),
            label: 'ALERTS',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (state.cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: BadgeBubble(
                      state.cartItems
                          .fold<int>(0, (sum, item) => sum + item.quantity)
                          .toString(),
                    ),
                  ),
              ],
            ),
            label: 'CART',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    final categories = ['Tất cả', 'Áo', 'Quần', 'Giày', 'Phụ kiện', 'Áo khoác'];
    final filtered = state.selectedCategory == 'Tất cả'
        ? productList
        : productList
              .where((item) => item.category == state.selectedCategory)
              .toList();
    final chunks = <List<Product>>[];
    for (var i = 0; i < filtered.length; i += 2) {
      chunks.add(
        filtered.sublist(i, i + 2 > filtered.length ? filtered.length : i + 2),
      );
    }
    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final selected = category == state.selectedCategory;
                  return ElevatedButton(
                    onPressed: () => state.selectCategory(category),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selected
                          ? SportZoneTheme.primary
                          : SportZoneTheme.surfaceVariant,
                      foregroundColor: selected
                          ? SportZoneTheme.onPrimary
                          : SportZoneTheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      category,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemCount: categories.length,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ['Nike', 'Adidas', 'Puma', 'Under Armour', 'Reebok']
                    .map((brand) {
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: SportZoneTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            brand.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: SportZoneTheme.secondary,
                                  letterSpacing: 1,
                                ),
                          ),
                        ),
                      );
                    })
                    .toList(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LATEST DROPS',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      color: SportZoneTheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            ...chunks.map(
              (rowProducts) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    for (var product in rowProducts)
                      Expanded(child: _ProductCard(product: product)),
                    if (rowProducts.length == 1) ...[const Spacer(flex: 1)],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final state = context.read<SportZoneState>();
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () =>
            Navigator.pushNamed(context, '/product', arguments: product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
                if (product.discount != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: BadgeTag(
                      text: product.discount ?? '',
                      isAccent: product.discount!.startsWith('-'),
                    ),
                  ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      state.addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
                      );
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: SportZoneTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: SportZoneTheme.onPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product.brand,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: SportZoneTheme.secondary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.name,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Flexible(
                  flex: 3,
                  child: Text(
                    formatVnd(product.price),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: SportZoneTheme.primary,
                      fontSize: 19,
                    ),
                  ),
                ),
                if (product.originalPrice != null) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    flex: 2,
                    child: Text(
                      formatVnd(product.originalPrice!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: SportZoneTheme.secondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({required this.product, super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String selectedColor = 'Black';
  String selectedSize = '40';
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    final recommended = productList
        .where((p) => p.id != widget.product.id)
        .take(2)
        .toList();
    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  Text(
                    'CHI TIẾT MẪU',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  _circleIconButton(icon: Icons.favorite_border, onTap: () {}),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: SportZoneTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.product.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width * 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.brand,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: SportZoneTheme.secondary,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.product.name.toUpperCase(),
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatVnd(widget.product.price),
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: SportZoneTheme.primary,
                                ),
                          ),
                          if (widget.product.originalPrice != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  formatVnd(widget.product.originalPrice!),
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        decoration: TextDecoration.lineThrough,
                                        color: SportZoneTheme.secondary,
                                      ),
                                ),
                                const SizedBox(width: 8),
                                BadgeTag(
                                  text: widget.product.discount ?? '',
                                  isAccent: true,
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 24),
                          const Divider(color: SportZoneTheme.borderSubtle),
                          const SizedBox(height: 24),
                          Text(
                            'MÀU SẮC',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _colorDot('Black', Colors.black),
                              const SizedBox(width: 12),
                              _colorDot('White', Colors.white),
                              const SizedBox(width: 12),
                              _colorDot('Red', const Color(0xFFE81E25)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'KÍCH CỠ',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              Text(
                                'Bảng size',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      decoration: TextDecoration.underline,
                                      color: SportZoneTheme.secondary,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: ['38', '39', '40', '41', '42'].map((
                              size,
                            ) {
                              final selected = selectedSize == size;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => selectedSize = size),
                                  child: Container(
                                    height: 44,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? SportZoneTheme.primary
                                          : SportZoneTheme.surfaceVariant,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      size,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: selected
                                                ? SportZoneTheme.onPrimary
                                                : SportZoneTheme.secondary,
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'SỐ LƯỢNG',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: SportZoneTheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove,
                                    color: SportZoneTheme.primary,
                                  ),
                                  onPressed: () {
                                    if (quantity > 1) {
                                      setState(() => quantity--);
                                    }
                                  },
                                ),
                                Text(
                                  quantity.toString(),
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: SportZoneTheme.primary,
                                  ),
                                  onPressed: () => setState(() => quantity++),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          AccordionItem(
                            title: 'MÔ TẢ SẢN PHẨM',
                            content: widget.product.description,
                          ),
                          AccordionItem(
                            title: 'CHẤT LIỆU',
                            content:
                                'Vật liệu dệt tổng hợp cao cấp, lưới thoáng khí kết hợp sợi carbon bảo vệ môi trường, mang lại cấu trúc bền bỉ đặc trị các giáo án tập luyện nặng.',
                          ),
                          AccordionItem(
                            title: 'BẢO HÀNH',
                            content:
                                'Bảo hành chính hãng 6 tháng cho các lỗi kỹ thuật từ nhà sản xuất. Đổi trả miễn phí nguyên hộp trong 30 ngày nếu chưa qua cắt mác hoặc sử dụng thực tế.',
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'CÓ THỂ BẠN SẼ THÍCH',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recommended.length,
                              padding: const EdgeInsets.only(right: 16),
                              itemBuilder: (context, index) {
                                final product = recommended[index];
                                return GestureDetector(
                                  onTap: () => state.addToCart(product),
                                  child: Container(
                                    width: 160,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.network(
                                            product.imageUrl,
                                            width: 160,
                                            height: 160,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          product.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          formatVnd(product.price),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: SportZoneTheme.secondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        color: SportZoneTheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SportZoneTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                state.addToCart(
                  widget.product,
                  size: selectedSize,
                  color: selectedColor,
                  quantity: quantity,
                );
                Navigator.pushNamed(context, '/main');
              },
              child: Text(
                'THÊM VÀO GIỎ HÀNG',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: SportZoneTheme.onPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _colorDot(String name, Color color) {
    final selected = selectedColor == name;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = name),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color.fromRGBO(158, 158, 158, 0.4),
            width: selected ? 3 : 1.5,
          ),
        ),
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: SportZoneTheme.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: SportZoneTheme.primary),
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    final items = state.cartItems;
    final subtotal = items.fold<int>(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
    final shippingFee = items.isEmpty ? 0 : 35000;
    final total = subtotal + shippingFee;
    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GIỎ HÀNG',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: SportZoneTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (items.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_bag,
                        size: 72,
                        color: Color(0xFF9E9E9E),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'GIỎ HÀNG HIỆN ĐANG RỖNG',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Trải nghiệm rải đồ với Latest Drops và lấp đầy túi đồ tập ngay thôi!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SportZoneTheme.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 260),
                  itemCount: items.length + 1,
                  separatorBuilder: (_, _) =>
                      const Divider(color: SportZoneTheme.borderSubtle),
                  itemBuilder: (context, index) {
                    if (index == items.length) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: SportZoneTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 48,
                              color: SportZoneTheme.electricLime,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ƯU ĐÃI ĐỘC QUYỀN',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: SportZoneTheme.primary,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Nhập mã SPORT20 để được giảm giá 20% cho đơn hàng tiếp theo.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: SportZoneTheme.secondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final item = items[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.imageUrl,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name.toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        state.deleteCartItem(item.id),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: SportZoneTheme.secondary,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Size: ${item.size} • Màu: ${item.color}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: SportZoneTheme.secondary),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatVnd(item.price),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: SportZoneTheme.primary,
                                        ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: SportZoneTheme.primary,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              state.updateCartItemQuantity(
                                                item.id,
                                                item.quantity - 1,
                                              ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            child: Text(
                                              '-',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: SportZoneTheme.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 24,
                                          color: SportZoneTheme.borderSubtle,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Text(
                                            item.quantity.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                ),
                                          ),
                                        ),
                                        Container(
                                          width: 1,
                                          height: 24,
                                          color: SportZoneTheme.borderSubtle,
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              state.updateCartItemQuantity(
                                                item.id,
                                                item.quantity + 1,
                                              ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            child: Text(
                                              '+',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: SportZoneTheme.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomSheet: items.isNotEmpty
          ? Container(
              width: double.infinity,
              color: SportZoneTheme.surface,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tạm tính',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SportZoneTheme.secondary,
                        ),
                      ),
                      Text(
                        formatVnd(subtotal),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Phí vận chuyển',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: SportZoneTheme.secondary,
                        ),
                      ),
                      Text(
                        formatVnd(shippingFee),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: SportZoneTheme.borderSubtle),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TỔNG CỘNG',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        formatVnd(total),
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: SportZoneTheme.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SportZoneTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/checkout'),
                      child: Text(
                        'THANH TOÁN',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: SportZoneTheme.onPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final fullName = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  String selectedPayment = 'COD';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    final subtotal = state.cartItems.fold<int>(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
    final shippingFee = 30000;
    const discount = 100000;
    final total = subtotal + shippingFee - discount;
    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      appBar: AppBar(
        title: const Text('SPORTZONE'),
        backgroundColor: SportZoneTheme.surface,
        foregroundColor: SportZoneTheme.primary,
        elevation: 1.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ĐƠN HÀNG CỦA BẠN',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: state.cartItems.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SportZoneTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name.toUpperCase(),
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w900),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Size: ${item.size} • Màu: ${item.color} • x${item.quantity}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: SportZoneTheme.secondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatVnd(item.price),
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: SportZoneTheme.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'THÔNG TIN GIAO HÀNG',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fullName,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: address,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ giao hàng (Số nhà, Phố, Quận, TP)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'PHƯƠNG THỨC THANH TOÁN',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              ...[
                PaymentOption(
                  code: 'COD',
                  label: 'Thanh toán khi nhận hàng (COD)',
                  icon: Icons.local_shipping,
                ),
                PaymentOption(
                  code: 'BANK',
                  label: 'Chuyển khoản ngân hàng',
                  icon: Icons.account_balance,
                ),
                PaymentOption(
                  code: 'WALLET',
                  label: 'Ví điện tử (Momo/ZaloPay)',
                  icon: Icons.account_balance_wallet,
                ),
              ].map((payment) {
                final selected = selectedPayment == payment.code;
                return GestureDetector(
                  onTap: () => setState(() => selectedPayment = payment.code),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SportZoneTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? SportZoneTheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(payment.icon, color: SportZoneTheme.primary),
                            const SizedBox(width: 12),
                            Text(
                              payment.label,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: SportZoneTheme.primary,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              _priceRow(context, 'Tạm tính:', subtotal),
              const SizedBox(height: 8),
              _priceRow(context, 'Phí vận chuyển:', shippingFee),
              const SizedBox(height: 8),
              _priceRow(context, 'Giảm giá:', -discount, negative: true),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        color: SportZoneTheme.surface,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TỔNG CỘNG',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: SportZoneTheme.secondary,
                  ),
                ),
                Text(
                  formatVnd(state.cartItems.isEmpty ? 0 : total),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SportZoneTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: state.cartItems.isEmpty
                    ? null
                    : () {
                        final name = fullName.text.isEmpty
                            ? 'Nguyễn Văn A'
                            : fullName.text.trim();
                        final addr = address.text.isEmpty
                            ? '123 Lê Lợi, Quận 1, TP.HCM'
                            : address.text.trim();
                        state.checkout(
                          name,
                          phone.text.trim(),
                          addr,
                          selectedPayment,
                        );
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/main',
                          (route) => route.isFirst,
                        );
                      },
                child: Text(
                  'ĐẶT HÀNG',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: SportZoneTheme.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(
    BuildContext context,
    String label,
    int amount, {
    bool negative = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: SportZoneTheme.secondary),
        ),
        Text(
          '${negative ? '- ' : ''}${formatVnd(amount.abs())}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: negative ? SportZoneTheme.error : SportZoneTheme.primary,
          ),
        ),
      ],
    );
  }
}

class PaymentOption {
  final String code;
  final String label;
  final IconData icon;
  const PaymentOption({
    required this.code,
    required this.label,
    required this.icon,
  });
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    final unreadCount = state.notifications
        .where((item) => !item.isRead)
        .length;
    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'THÔNG BÁO',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: SportZoneTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unreadCount MỚI',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: SportZoneTheme.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SportZoneTheme.surface,
                  foregroundColor: SportZoneTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  side: const BorderSide(
                    color: SportZoneTheme.primary,
                    width: 1.5,
                  ),
                ),
                onPressed: state.markAllNotificationsRead,
                child: Text(
                  'ĐÁNH DẤU TẤT CẢ LÀ ĐÃ ĐỌC',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: state.notifications.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.notifications.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: SportZoneTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuBsRNg5USYDRHIBxye5vzURNc61PCkEyDNyC2-FlTtL9_3deNbAwpHw6Ty7GROg631dZWdDK_QveVq95P9OUtdvzXWjUknf3Sp2MO7vKIr3-4Ca2YleYi45MED1IDDoTvoomEpix0gL0egG-STYmFYCYZ9d6MhkoSDtCiYDMqj0WJgmQVZn0U_faA_s51xbvpNl1mbwQKbtPwQq8zhNABuqtv_rG9K-bUrDLHzK-xjytwSTx0A22snSH6cGMiayLtN6oIp-MZd6vt4',
                                width: double.infinity,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'KEEP GRINDING',
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    color: SportZoneTheme.onPrimary,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Đừng để các thông báo lỡ nhịp tập luyện của bạn. Cập nhật mẫu drops mới nhất ngay.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final item = state.notifications[index];
                  return Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: item.isRead
                              ? SportZoneTheme.surface
                              : SportZoneTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: SportZoneTheme.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item.category == 'DELIVERY'
                                    ? Icons.local_shipping
                                    : item.category == 'PROMO'
                                    ? Icons.confirmation_number
                                    : Icons.sell,
                                color: SportZoneTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (!item.isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: SportZoneTheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      if (!item.isRead)
                                        const SizedBox(width: 8),
                                      Text(
                                        item.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: item.isRead
                                                  ? SportZoneTheme.secondary
                                                  : SportZoneTheme.primary,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.content,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: SportZoneTheme.secondary,
                                          height: 1.4,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.timeAgo,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: const Color.fromRGBO(
                                            93,
                                            95,
                                            95,
                                            0.7,
                                          ),
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (!item.isRead)
                              Container(
                                width: 4,
                                height: 44,
                                color: SportZoneTheme.electricLime,
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SPORTZONE SUPPORT',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    onPressed: state.clearChat,
                    icon: const Icon(
                      Icons.delete_sweep,
                      color: SportZoneTheme.error,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: SportZoneTheme.borderSubtle),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                itemCount:
                    state.chatMessages.length + (state.isBotTyping ? 1 : 0) + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: SportZoneTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'HÔM NAY',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: SportZoneTheme.secondary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    );
                  }
                  final msgIndex = index - 1;
                  if (msgIndex < state.chatMessages.length) {
                    final msg = state.chatMessages[msgIndex];
                    return _chatBubble(msg);
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: SportZoneTheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Bots đang soạn tin nhắn...',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: SportZoneTheme.secondary),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              color: SportZoneTheme.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: SportZoneTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: SportZoneTheme.primary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn tư vấn...',
                        filled: true,
                        fillColor: SportZoneTheme.surfaceVariant,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      onSubmitted: (_) => _send(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _send(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: SportZoneTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: SportZoneTheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatBubble(ChatMessage msg) {
    final alignEnd = msg.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: alignEnd
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!alignEnd)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: SportZoneTheme.electricLime,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.support_agent,
                        size: 12,
                        color: SportZoneTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SPORTZONE BOT',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: alignEnd ? Colors.black : SportZoneTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                msg.message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: alignEnd ? Colors.white : SportZoneTheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _send(BuildContext context) {
    final state = context.read<SportZoneState>();
    final text = controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    controller.clear();
    state.sendChatMessage(text);
  }
}

class StoreLocationScreen extends StatefulWidget {
  const StoreLocationScreen({super.key});

  @override
  State<StoreLocationScreen> createState() => _StoreLocationScreenState();
}

class _StoreLocationScreenState extends State<StoreLocationScreen> {
  bool isMutedMap = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCeX0Ie7HHcWaSYC5_A8VtMYXIndKwbivdqY3Rji7URMItPKu9RyMz8rD2XJ7RPSx-BxSpp4zFJVp7JidRdjdi7DDo8HDdRbJK4V-ytryGBrQf40ScQdhtYQzZxmgASggswYiePuljqJGclkOsX7zFSCNiE7pkzF96zs6IF51wpRF4VG6_FVM84E7nU3cwoXuRRgtEVjnDXFS5Bfoor6PHXziVKu-Idi8qL1YsP7d7aU8b5LrNDJ0r9drdplCn014oM1yJUzYqagXI',
              fit: BoxFit.cover,
              colorBlendMode: isMutedMap ? BlendMode.saturation : BlendMode.dst,
              color: isMutedMap ? Colors.grey : null,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: SportZoneTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: SportZoneTheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: SportZoneTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 96,
            right: 16,
            child: Column(
              children: [
                _mapAction(icon: Icons.add, onTap: () {}),
                const SizedBox(height: 8),
                _mapAction(icon: Icons.remove, onTap: () {}),
                const SizedBox(height: 8),
                _mapAction(
                  icon: Icons.my_location,
                  onTap: () => setState(() => isMutedMap = !isMutedMap),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 96,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SportZoneTheme.primary, width: 4),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: SportZoneTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BadgeTag(text: 'FLAGSHIP', isAccent: true),
                          const SizedBox(height: 6),
                          Text(
                            'SportZone Flagship Store',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            '123 Lê Lợi, Quận 1, TP.HCM',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: SportZoneTheme.secondary),
                          ),
                        ],
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: SportZoneTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.store,
                          color: SportZoneTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: SportZoneTheme.borderSubtle),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.call,
                                color: SportZoneTheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PHONE',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: SportZoneTheme.secondary,
                                        ),
                                  ),
                                  Text(
                                    '+84 28 3456 7890',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.schedule,
                                color: SportZoneTheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'OPEN UNTIL',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: SportZoneTheme.secondary,
                                        ),
                                  ),
                                  Text(
                                    '22:00 PM',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SportZoneTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'CHỈ ĐƯỜNG',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: SportZoneTheme.onPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.directions_run,
                            size: 18,
                            color: SportZoneTheme.onPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapAction({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SportZoneTheme.primary),
        ),
        child: Icon(icon, color: SportZoneTheme.primary),
      ),
    );
  }
}

class BadgeTag extends StatelessWidget {
  final String text;
  final bool isAccent;
  const BadgeTag({required this.text, required this.isAccent, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAccent ? SportZoneTheme.electricLime : SportZoneTheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isAccent ? SportZoneTheme.primary : SportZoneTheme.onPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }
}

class AccordionItem extends StatefulWidget {
  final String title;
  final String content;
  const AccordionItem({required this.title, required this.content, super.key});

  @override
  State<AccordionItem> createState() => _AccordionItemState();
}

class _AccordionItemState extends State<AccordionItem> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                Icon(expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              widget.content,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: SportZoneTheme.secondary),
            ),
          ),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        const Divider(color: SportZoneTheme.borderSubtle),
      ],
    );
  }
}

String formatVnd(int value) {
  final text = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final position = text.length - i;
    buffer.write(text[i]);
    if (position > 1 && position % 3 == 1) {
      buffer.write('.');
    }
  }
  return '${value < 0 ? '-' : ''}${buffer.toString()}đ';
}

class BadgeBubble extends StatelessWidget {
  final String text;
  const BadgeBubble(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: SportZoneTheme.electricLime,
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: SportZoneTheme.primary,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
