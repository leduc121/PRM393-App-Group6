import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/shop_provider.dart';
import '../../data/database.dart';
import '../theme.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _countSelected = 1;
  Product? _cachedProduct;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);
    final product = productsAsync.when(
      data: (list) {
        final found = list.where((p) => p.id == widget.productId).firstOrNull;
        if (found != null) {
          _cachedProduct = found;
        }
        return found ?? _cachedProduct;
      },
      loading: () => _cachedProduct,
      error: (_, __) => _cachedProduct,
    );

    if (product == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AeroColors.aeroOrange),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Toolbar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    ref.read(shopProvider.notifier).navigateTo(ActiveScreen.home);
                  },
                  icon: const Icon(Icons.arrow_back),
                  style: IconButton.styleFrom(
                    backgroundColor: AeroColors.aeroM3Container,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Chi tiết sản phẩm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AeroColors.aeroTextPrimaryDark,
                  ),
                ),
              ],
            ),
          ),
          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Header
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFEF7FF), Color(0xFFEADDFF)],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: _getCategoryColor(product.category),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getCategoryIcon(product.category),
                            color: Colors.white,
                            size: 54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'AEROSPORT ${product.category.toUpperCase()} COLLECTION',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Specifications and details
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and rating
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AeroColors.aeroTextPrimaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Color(0xFFFFB300), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${product.rating} (${product.reviewCount} Khách hàng đánh giá)',
                              style: const TextStyle(
                                color: AeroColors.aeroTextSecondaryDark,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Price details card
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: AeroColors.aeroM3Container,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Giá hội viên ưu đãi',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AeroColors.aeroTextSecondaryDark,
                                    ),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '\$${product.price}',
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          color: AeroColors.aeroOrange,
                                        ),
                                      ),
                                      if (product.originalPrice > product.price) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '\$${product.originalPrice}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AeroColors.aeroTextSecondaryDark,
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              // Stock availability
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: product.stock > 0
                                      ? AeroColors.aeroEmerald.withOpacity(0.15)
                                      : Colors.red.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product.stock > 3
                                      ? "Còn hàng (${product.stock})"
                                      : product.stock > 0
                                          ? "Sắp hết (${product.stock})"
                                          : "Hết hàng",
                                  style: TextStyle(
                                    color: product.stock > 0
                                        ? AeroColors.aeroEmerald
                                        : Colors.red,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Description
                        const Text(
                          'MÔ TẢ SẢN PHẨM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AeroColors.aeroOrange,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: const TextStyle(
                            color: AeroColors.aeroTextPrimaryDark,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Technical Specifications
                        const Text(
                          'THÔNG SỐ KỸ THUẬT & LỰA CHỌN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AeroColors.aeroOrange,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AeroColors.aeroM3Container,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _parseSpecs(product.specs),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Floating Bottom checkout bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                // Selector Row counter
                Container(
                  decoration: BoxDecoration(
                    color: AeroColors.aeroM3Container,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_countSelected > 1) {
                            setState(() {
                              _countSelected--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove, color: AeroColors.aeroOrange),
                      ),
                      Text(
                        '$_countSelected',
                        style: const TextStyle(
                          color: AeroColors.aeroTextPrimaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (_countSelected < product.stock) {
                            setState(() {
                              _countSelected++;
                            });
                          }
                        },
                        icon: const Icon(Icons.add, color: AeroColors.aeroOrange),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Add quantity to cart button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: product.stock > 0
                          ? () async {
                              await ref
                                  .read(shopProvider.notifier)
                                  .addToCart(product.id, quantity: _countSelected);
                              ref
                                  .read(shopProvider.notifier)
                                  .navigateTo(ActiveScreen.cart);
                            }
                          : null,
                      icon: const Icon(Icons.shopping_cart, color: Colors.white),
                      label: Text(
                        'ĐẶT GIỎ HÀNG (\$${(product.price * _countSelected).toStringAsFixed(2)})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AeroColors.aeroOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Nutrition":
        return const Color(0xFFEA580C);
      case "Gym Gear":
        return const Color(0xFF0D9488);
      default:
        return const Color(0xFF2563EB);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Nutrition":
        return Icons.local_activity;
      case "Gym Gear":
        return Icons.fitness_center;
      default:
        return Icons.checkroom;
    }
  }

  List<Widget> _parseSpecs(String specs) {
    final lines = specs.split("\n");
    final widgets = <Widget>[];

    for (var spec in lines) {
      final parts = spec.split(":");
      if (parts.length >= 2) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${parts[0].trim()}:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AeroColors.aeroTextSecondaryDark,
                  ),
                ),
                Text(
                  parts.sublist(1).join(":").trim(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AeroColors.aeroTextPrimaryDark,
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (spec.trim().isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              spec,
              style: const TextStyle(
                fontSize: 12,
                color: AeroColors.aeroTextPrimaryDark,
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}
