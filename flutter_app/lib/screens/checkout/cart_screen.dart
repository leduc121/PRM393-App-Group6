import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';


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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: SportZoneTheme.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, size: 20),
                      ),
                    ),
                  ),
                  Column(
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
                          child: SizedBox(
                            width: 96,
                            height: 96,
                            child: ProductImage(
                              imageUrl: item.imageUrl,
                              productName: item.name,
                            ),
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

