import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/shop_provider.dart';
import '../../data/database.dart';
import '../theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shopProvider);
    final productsAsync = ref.watch(productsStreamProvider);
    final cartItemsAsync = ref.watch(cartItemsStreamProvider);

    final products = productsAsync.value ?? [];
    final cartItems = cartItemsAsync.value ?? [];

    // Filter products
    final filteredProducts = products.where((product) {
      final matchesCategory = state.selectedCategory == "Tất cả" ||
          product.category == state.selectedCategory;
      final matchesKeyword = product.name
              .toLowerCase()
              .contains(state.searchKeyword.toLowerCase()) ||
          product.description
              .toLowerCase()
              .contains(state.searchKeyword.toLowerCase());
      return matchesCategory && matchesKeyword;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          // App top header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.electric_bolt,
                          color: AeroColors.aeroOrange,
                          size: 24,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'AEROSPORT',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AeroColors.aeroOrange,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Chào mừng, ${state.currentUserName} 👋',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AeroColors.aeroTextSecondaryDark,
                      ),
                    ),
                  ],
                ),
                // Power/Logout Button
                IconButton(
                  onPressed: () {
                    ref.read(shopProvider.notifier).logoutUser();
                  },
                  icon: const Icon(
                    Icons.power_settings_new,
                    color: Colors.red,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AeroColors.aeroM3Container,
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),
          // Custom search bar field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              onChanged: (val) {
                ref.read(shopProvider.notifier).updateSearchKeyword(val);
              },
              decoration: InputDecoration(
                hintText: 'Tìm Whey Isolate, tạ kettlebell, đồ tập...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: state.searchKeyword.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          ref.read(shopProvider.notifier).updateSearchKeyword("");
                        },
                      )
                    : null,
                filled: true,
                fillColor: AeroColors.aeroM3Container,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Horizontal Categories Filters selector
          _buildCategoryFilterList(ref, state.selectedCategory),
          const SizedBox(height: 16),
          // Product List
          Expanded(
            child: productsAsync.when(
              data: (_) {
                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AeroColors.aeroTextSecondaryDark,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Không tìm thấy sản phẩm nào phù hợp!',
                          style: TextStyle(
                            color: AeroColors.aeroTextSecondaryDark,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemCount: filteredProducts.length + 1, // +1 for the promotional banner
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildPromoBanner(ref);
                    }
                    final product = filteredProducts[index - 1];
                    final cartCount = cartItems
                        .where((item) => item.productId == product.id)
                        .firstOrNull
                        ?.quantity ??
                        0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ProductRowCard(
                        product: product,
                        cartCount: cartCount,
                        onTap: () {
                          ref
                              .read(shopProvider.notifier)
                              .navigateTo(ActiveScreen.productDetail, productId: product.id);
                        },
                        onAddToCart: () {
                          ref.read(shopProvider.notifier).addToCart(product.id, quantity: 1);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AeroColors.aeroOrange),
              ),
              error: (err, stack) => Center(
                child: Text('Lỗi kết nối: ${err.toString()}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterList(WidgetRef ref, String currentSelection) {
    final categories = ["Tất cả", "Nutrition", "Gym Gear", "Apparel"];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = currentSelection == cat;
          String label;
          switch (cat) {
            case "Tất cả":
              label = "Tất cả 🛒";
              break;
            case "Nutrition":
              label = "Dinh dưỡng 💪";
              break;
            case "Gym Gear":
              label = "Trang thiết bị 🏋️‍♂️";
              break;
            case "Apparel":
              label = "Thời trang đồ tập 🏃‍♂️";
              break;
            default:
              label = cat;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isSelected ? const Color(0xFF21005D) : const Color(0xFF49454F),
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFFEADDFF),
              backgroundColor: const Color(0xFFF3EDF7),
              onSelected: (selected) {
                if (selected) {
                  ref.read(shopProvider.notifier).updateCategory(cat);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoBanner(WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: AeroColors.aeroOrange,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ƯU ĐÃI ĐỘC QUYỀN AI ⚡',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Giảm 10% Cho Hội Viên',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Hỏi Chatbot để nhận mã CODE khuyến mãi Aero!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                ref.read(shopProvider.notifier).navigateTo(ActiveScreen.chat);
              },
              icon: const Icon(Icons.chat, color: AeroColors.aeroOrange),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductRowCard extends StatelessWidget {
  final Product product;
  final int cartCount;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductRowCard({
    super.key,
    required this.product,
    required this.cartCount,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Product visual badge based on category
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _getCategoryGradient(),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getCategoryIcon(),
                      color: Colors.white,
                      size: 36,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.tag.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AeroColors.aeroOrange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.tag,
                          style: const TextStyle(
                            color: AeroColors.aeroOrange,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AeroColors.aeroTextPrimaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFFB300), size: 12),
                        const SizedBox(width: 2),
                        Text(
                          '${product.rating}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AeroColors.aeroTextPrimaryDark,
                          ),
                        ),
                        Text(
                          ' (${product.reviewCount} đánh giá)',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AeroColors.aeroTextSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Prices
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${product.price}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AeroColors.aeroOrange,
                          ),
                        ),
                        if (product.originalPrice > product.price) ...[
                          const SizedBox(width: 6),
                          Text(
                            '\$${product.originalPrice}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AeroColors.aeroTextSecondaryDark,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Cart Actions
              const SizedBox(width: 6),
              Stack(
                alignment: Alignment.topRight,
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: onAddToCart,
                    icon: const Icon(Icons.add),
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: AeroColors.aeroOrange,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getCategoryGradient() {
    switch (product.category) {
      case "Nutrition":
        return [const Color(0xFFEA580C), const Color(0xFF9A3412)];
      case "Gym Gear":
        return [const Color(0xFF0D9488), const Color(0xFF0F766E)];
      default:
        return [const Color(0xFF2563EB), const Color(0xFF1D4ED8)];
    }
  }

  IconData _getCategoryIcon() {
    switch (product.category) {
      case "Nutrition":
        return Icons.local_activity;
      case "Gym Gear":
        return Icons.fitness_center;
      default:
        return Icons.checkroom;
    }
  }
}
