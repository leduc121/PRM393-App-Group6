import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api_service.dart';


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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
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
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: ProductImage(
                              imageUrl: item.imageUrl,
                              productName: item.name,
                            ),
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
                PaymentOption(
                  code: 'stripe',
                  label: 'Thẻ quốc tế (Stripe)',
                  icon: Icons.credit_card,
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
                    : () async {
                        final name = fullName.text.isEmpty
                            ? 'Nguyễn Văn A'
                            : fullName.text.trim();
                        final phoneStr = phone.text.isEmpty
                            ? '0900000000'
                            : phone.text.trim();
                        final addr = address.text.isEmpty
                            ? '123 Lê Lợi, Quận 1, TP.HCM'
                            : address.text.trim();
                        
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator()),
                        );
                        
                        final result = await state.checkout(
                          recipientName: name,
                          phone: phoneStr,
                          street: addr,
                          paymentMethod: selectedPayment,
                        );
                        
                        if (!mounted) return;
                        Navigator.pop(context); // Pop loading dialog
                        
                        if (result.isSuccess) {
                          if (selectedPayment == 'stripe') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đang chuyển hướng sang Stripe...')),
                            );
                            final orderId = result.data['orderId'];
                            if (orderId != null) {
                              final stripeResult = await ApiService.createStripeCheckoutSession(orderId);
                              if (stripeResult.isSuccess && stripeResult.data['checkoutUrl'] != null) {
                                final url = Uri.parse(stripeResult.data['checkoutUrl']);
                                await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(stripeResult.errorMessage ?? 'Không thể mở trang thanh toán Stripe')),
                                );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đặt hàng thành công!')),
                            );
                          }

                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/main',
                            (route) => route.isFirst,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result.errorMessage ?? 'Đặt hàng thất bại')),
                          );
                        }
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

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

