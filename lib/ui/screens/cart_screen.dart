import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/shop_provider.dart';
import '../theme.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _showCheckoutScreen = false;
  bool _showSuccessReceiptScreen = false;
  final _promoController = TextEditingController();
  final _addressController = TextEditingController();
  int _receiptNumber = 0;

  @override
  void initState() {
    super.initState();
    _receiptNumber = 1000 + Random().nextInt(9000);
  }

  @override
  void dispose() {
    _promoController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopProvider);
    final productsAsync = ref.watch(productsStreamProvider);
    final cartItemsAsync = ref.watch(cartItemsStreamProvider);

    final products = productsAsync.value ?? [];
    final cartItems = cartItemsAsync.value ?? [];

    // Map cart items
    final itemsToRender = cartItems.map((item) {
      final product = products.where((p) => p.id == item.productId).firstOrNull;
      return MapEntry(product, item.quantity);
    }).where((entry) => entry.key != null).toList();

    // Calculations
    final double subtotal = itemsToRender.fold(0.0, (sum, entry) => sum + (entry.key!.price * entry.value));
    final double savings = state.isPromoApplied ? subtotal * 0.1 : 0.0;
    final double shipping = subtotal > 0 ? 4.99 : 0.0;
    final double total = subtotal - savings + shipping;

    final String itemDetailsString = itemsToRender.map((entry) => "${entry.key!.name} x${entry.value}").join("; ");

    // 1. Success Receipt view
    if (_showSuccessReceiptScreen) {
      return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AeroColors.aeroEmerald.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AeroColors.aeroEmerald,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'ĐẶT HÀNG THÀNH CÔNG! 🎉',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'AeroSport chân thành cảm ơn sự đồng hành của bạn!',
                  style: TextStyle(
                    fontSize: 12,
                    color: AeroColors.aeroTextSecondaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Visual physical ticket
                Card(
                  color: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HÓA ĐƠN ĐƠN HÀNG #AERO$_receiptNumber',
                          style: const TextStyle(
                            color: AeroColors.aeroOrangeLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Divider(color: Color(0xFF334155), height: 24),
                        const Text(
                          'Sản phẩm chọn mua:',
                          style: TextStyle(
                            fontSize: 11,
                            color: AeroColors.aeroTextSecondaryDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...itemsToRender.map((entry) {
                          final product = entry.key!;
                          final qty = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'x$qty   \$${(product.price * qty).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const Divider(color: Color(0xFF334155), height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng số tiền:',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Vận chuyển:',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            Text(
                              'Giao hàng nội hạt (2-4h)',
                              style: TextStyle(
                                color: AeroColors.aeroEmerald,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showSuccessReceiptScreen = false;
                      });
                      ref.read(shopProvider.notifier).navigateTo(ActiveScreen.home);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AeroColors.aeroOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'VỀ TRANG CHỦ',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. Checkout view
    if (_showCheckoutScreen) {
      if (_addressController.text.isEmpty && state.checkoutAddress.isNotEmpty) {
        _addressController.text = state.checkoutAddress;
      }

      return Scaffold(
        body: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showCheckoutScreen = false;
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: AeroColors.aeroM3Container,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Xác nhận đặt hàng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AeroColors.aeroTextPrimaryDark,
                    ),
                  ),
                ],
              ),
            ),
            // Form body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VẬN CHUYỂN & HÌNH THỨC THANH TOÁN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AeroColors.aeroOrange,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Address Input
                    TextField(
                      controller: _addressController,
                      onChanged: (val) {
                        ref.read(shopProvider.notifier).updateCheckoutAddress(val);
                      },
                      decoration: InputDecoration(
                        labelText: 'Địa chỉ giao hàng (Số nhà, đường, quận...)',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chọn hình thức thanh toán:',
                      style: TextStyle(
                        color: AeroColors.aeroTextPrimaryDark,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Payment Toggle Card
                    _buildPaymentMethodTile("Thanh toán tiền mặt khi giao (COD)"),
                    _buildPaymentMethodTile("Chuyển khoản Ngân hàng nội địa"),
                    _buildPaymentMethodTile("Thẻ VISA / Mastercard"),
                    const SizedBox(height: 24),
                    // Cost Recap Card
                    Card(
                      color: AeroColors.aeroM3Container,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Giá gốc giỏ hàng', style: TextStyle(color: AeroColors.aeroTextSecondaryDark, fontSize: 13)),
                                Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(color: AeroColors.aeroTextPrimaryDark, fontSize: 13)),
                              ],
                            ),
                            if (state.isPromoApplied) ...[
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Giảm giá 10% (Voucher)', style: TextStyle(color: AeroColors.aeroEmerald, fontSize: 13)),
                                  Text('-\$${savings.toStringAsFixed(2)}', style: const TextStyle(color: AeroColors.aeroEmerald, fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Phí vận chuyển', style: TextStyle(color: AeroColors.aeroTextSecondaryDark, fontSize: 13)),
                                Text('\$${shipping.toStringAsFixed(2)}', style: const TextStyle(color: AeroColors.aeroTextPrimaryDark, fontSize: 13)),
                              ],
                            ),
                            const Divider(color: AeroColors.aeroM3Outline, height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('TỔNG SỐ TIỀN', style: TextStyle(color: AeroColors.aeroTextPrimaryDark, fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(
                                  '\$${total.toStringAsFixed(2)}',
                                  style: const TextStyle(color: AeroColors.aeroOrange, fontWeight: FontWeight.w900, fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Bottom button
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(shopProvider.notifier).placeOrder(
                      total: total,
                      itemDetails: itemDetailsString,
                      onOrderCompleted: () {
                        setState(() {
                          _showCheckoutScreen = false;
                          _showSuccessReceiptScreen = true;
                          _receiptNumber = 1000 + Random().nextInt(9000);
                        });
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AeroColors.aeroOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'ĐẶT HÀNG NGAY (${state.checkoutPaymentMethod.split(" ").first})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 3. Main Cart View
    return Scaffold(
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              children: const [
                Icon(
                  Icons.shopping_cart,
                  color: AeroColors.aeroOrange,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Giỏ Hàng Của Bạn',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AeroColors.aeroTextPrimaryDark,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: itemsToRender.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.shopping_cart_outlined,
                          size: 72,
                          color: AeroColors.aeroTextSecondaryDark,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Giỏ hàng hiện đang trống!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AeroColors.aeroTextPrimaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Hãy khám phá hàng trăm đồ tập và supplements hấp dẫn.',
                          style: TextStyle(color: AeroColors.aeroTextSecondaryDark, fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(shopProvider.notifier).navigateTo(ActiveScreen.home);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AeroColors.aeroOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'ĐI SẮM ĐỒ NGAY 💪',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // List of items
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: itemsToRender.length + 1, // +1 for the promo panel
                          itemBuilder: (context, index) {
                            if (index == itemsToRender.length) {
                              return _buildVoucherPanel(state);
                            }
                            final entry = itemsToRender[index];
                            final product = entry.key!;
                            final qty = entry.value;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(product.category),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _getCategoryIcon(product.category),
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              style: const TextStyle(
                                                color: AeroColors.aeroTextPrimaryDark,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '\$${product.price} / chiếc',
                                              style: const TextStyle(
                                                color: AeroColors.aeroTextSecondaryDark,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Quantity controls
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AeroColors.aeroM3Container,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                ref
                                                    .read(shopProvider.notifier)
                                                    .updateCartQuantity(product.id, qty - 1);
                                              },
                                              icon: const Icon(Icons.remove, size: 16),
                                              constraints: const BoxConstraints(
                                                minWidth: 28,
                                                minHeight: 28,
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                            Text(
                                              '$qty',
                                              style: const TextStyle(
                                                color: AeroColors.aeroTextPrimaryDark,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                ref
                                                    .read(shopProvider.notifier)
                                                    .updateCartQuantity(product.id, qty + 1);
                                              },
                                              icon: const Icon(Icons.add, size: 16),
                                              constraints: const BoxConstraints(
                                                minWidth: 28,
                                                minHeight: 28,
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Summary ticket panel
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E293B),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Tổng tiền hàng', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                              ],
                            ),
                            if (state.isPromoApplied) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Ưu đãi voucher (10%)', style: TextStyle(color: AeroColors.aeroEmerald, fontSize: 13)),
                                  Text('-\$${savings.toStringAsFixed(2)}', style: const TextStyle(color: AeroColors.aeroEmerald, fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Ship cơ bản nội hạt', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                Text('\$${shipping.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                              ],
                            ),
                            const Divider(color: Color(0xFF334155), height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Tổng Thanh Toán', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text(
                                      '\$${total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AeroColors.aeroOrangeLight,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showCheckoutScreen = true;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AeroColors.aeroOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                  child: const Text(
                                    'TIẾN HÀNH THANH TOÁN',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(String method) {
    final state = ref.watch(shopProvider);
    final isSelected = state.checkoutPaymentMethod == method;

    return Card(
      color: isSelected ? AeroColors.aeroOrange.withOpacity(0.15) : const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AeroColors.aeroOrange : Colors.transparent,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        onTap: () {
          ref.read(shopProvider.notifier).updateCheckoutPaymentMethod(method);
        },
        leading: Radio<String>(
          value: method,
          groupValue: state.checkoutPaymentMethod,
          activeColor: AeroColors.aeroOrange,
          onChanged: (val) {
            if (val != null) {
              ref.read(shopProvider.notifier).updateCheckoutPaymentMethod(val);
            }
          },
        ),
        title: Text(
          method,
          style: const TextStyle(
            color: AeroColors.aeroTextPrimaryDark,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVoucherPanel(ShopState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MÃ GIẢM GIÁ / VOUCHER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AeroColors.aeroOrange,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoController,
                  decoration: InputDecoration(
                    hintText: 'Mã Coupon (Ví dụ: AEROFIT10)',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    filled: true,
                    fillColor: AeroColors.aeroM3Container,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_promoController.text.isNotEmpty) {
                      ref.read(shopProvider.notifier).applyPromo(_promoController.text);
                      _promoController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AeroColors.aeroOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ÁP DỤNG',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          if (state.isPromoApplied) ...[
            const SizedBox(height: 8),
            Card(
              color: AeroColors.aeroEmerald.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AeroColors.aeroEmerald),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.check, color: AeroColors.aeroEmerald, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Hợp lệ: Giảm giá 10% đã kích hoạt',
                          style: TextStyle(color: AeroColors.aeroEmerald, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AeroColors.aeroEmerald, size: 16),
                      onPressed: () {
                        ref.read(shopProvider.notifier).removePromo();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (state.promoMessage.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              state.promoMessage,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
}
