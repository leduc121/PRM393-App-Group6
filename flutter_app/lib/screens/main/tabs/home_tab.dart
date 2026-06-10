import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';

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
                    child: ProductImage(
                      imageUrl: product.imageUrl,
                      productName: product.name,
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    final categories = ['Tất cả', ...state.apiCategories.map((c) => c.name)];
    final brands = ['Tất cả', ...state.apiBrands.map((b) => b.name)];

    final filtered = state.apiProducts;
    final chunks = <List<Product>>[];
    for (var i = 0; i < filtered.length; i += 2) {
      chunks.add(
        filtered.sublist(i, i + 2 > filtered.length ? filtered.length : i + 2),
      );
    }

    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: SportZoneTheme.electricLime,
              backgroundImage:
                  state.currentUser?.avatarUrl != null &&
                      state.currentUser!.avatarUrl!.isNotEmpty
                  ? NetworkImage(state.currentUser!.avatarUrl!)
                  : null,
              child:
                  state.currentUser?.avatarUrl == null ||
                      state.currentUser!.avatarUrl!.isEmpty
                  ? Text(
                      (state.currentUser?.name.isNotEmpty == true)
                          ? state.currentUser!.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chào, ${state.currentUser?.name ?? "Khách"}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  state.currentUser?.role?.toUpperCase() == 'ADMIN'
                      ? 'Quản trị viên'
                      : 'Thành viên',
                  style: TextStyle(
                    color: state.currentUser?.role?.toUpperCase() == 'ADMIN'
                        ? Colors.red
                        : Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (state.currentUser?.role?.toUpperCase() == 'ADMIN')
            TopActionButton(
              icon: Icons.admin_panel_settings_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminProductListScreen()),
              ),
            ),

          TopActionButton(
            icon: Icons.notifications_outlined,
            badgeText: state.notifications.any((n) => !n.isRead) ? '!' : null,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AlertsScreen()),
            ),
          ),
          TopActionButton(
            icon: Icons.shopping_cart_outlined,
            badgeText: state.cartItems.isNotEmpty
                ? state.cartItems
                      .fold<int>(0, (sum, item) => sum + item.quantity)
                      .toString()
                : null,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              state.fetchCategories(),
              state.fetchBrands(),
              state.fetchProducts(
                categoryId: state.selectedCategoryId,
                brandId: state.selectedBrandId,
              ),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: SportZoneTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: SportZoneTheme.secondary),
                            const SizedBox(width: 8),
                            Text(
                              'Tìm kiếm sản phẩm...',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: SportZoneTheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const FilterBottomSheet(),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: SportZoneTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: SportZoneTheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.tune, color: SportZoneTheme.onPrimary),
                            if (state.filterMinPrice != null || state.filterMaxPrice != null || state.filterGender != null || state.filterSize != null || state.selectedCategoryId != null || state.selectedBrandId != null)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: SportZoneTheme.electricLime,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
              if (state.isLoadingProducts)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Đang cập nhật xu hướng...',
                          style: TextStyle(
                            color: SportZoneTheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (state.apiProducts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.sentiment_dissatisfied_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Không tìm thấy sản phẩm nào.',
                          style: TextStyle(
                            fontSize: 16,
                            color: SportZoneTheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Hãy thử chọn danh mục hoặc hãng khác nhé!',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
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
      ),
    );
  }
}

