import 'package:flutter/material.dart';
import 'package:flutter_app/core.dart';

class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  late Future<ApiResult> _ordersFuture;

  static const _steps = [
    _OrderStep('Chờ xác nhận', Icons.receipt_long_outlined),
    _OrderStep('Chờ lấy hàng', Icons.inventory_2_outlined),
    _OrderStep('Chờ giao hàng', Icons.local_shipping_outlined),
    _OrderStep('Đánh giá', Icons.star_border_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _ordersFuture = ApiService.getMyOrders();
  }

  void _reload() {
    setState(() {
      _ordersFuture = ApiService.getMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      appBar: AppBar(
        backgroundColor: SportZoneTheme.surface,
        foregroundColor: SportZoneTheme.primary,
        elevation: 0,
        title: const Text(
          'Trạng thái đơn hàng',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: FutureBuilder<ApiResult>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final result = snapshot.data;
          if (result == null || !result.isSuccess) {
            return _StateMessage(
              icon: Icons.error_outline,
              title: 'Không tải được đơn hàng',
              message: result?.errorMessage ?? 'Vui lòng thử lại sau.',
              actionLabel: 'Tải lại',
              onAction: _reload,
            );
          }

          final raw = result.data;
          final list = raw is List ? raw : <dynamic>[];
          final orders = list
              .whereType<Map<String, dynamic>>()
              .map(Order.fromJson)
              .toList();

          if (orders.isEmpty) {
            return _StateMessage(
              icon: Icons.shopping_bag_outlined,
              title: 'Chưa có đơn hàng',
              message: 'Các đơn đã thanh toán sẽ xuất hiện ở đây.',
              actionLabel: 'Tải lại',
              onAction: _reload,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              itemBuilder: (context, index) =>
                  _OrderStatusCard(order: orders[index], steps: _steps),
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemCount: orders.length,
            ),
          );
        },
      ),
    );
  }
}

class _OrderStatusCard extends StatelessWidget {
  final Order order;
  final List<_OrderStep> steps;

  const _OrderStatusCard({required this.order, required this.steps});

  @override
  Widget build(BuildContext context) {
    final activeStep = _activeStepFor(order.status);
    final cancelled = order.status == 'cancelled';

    return Container(
      decoration: BoxDecoration(
        color: SportZoneTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SportZoneTheme.borderSubtle),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đơn #${_shortId(order.id)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dateLabel(order.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: SportZoneTheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cancelled
                      ? SportZoneTheme.error.withValues(alpha: 0.08)
                      : SportZoneTheme.electricLime.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(order.status),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cancelled
                        ? SportZoneTheme.error
                        : SportZoneTheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (cancelled)
            _CancelledOrderNotice()
          else
            Row(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  Expanded(
                    child: _StepNode(
                      step: steps[i],
                      active: i <= activeStep,
                      current: i == activeStep,
                    ),
                  ),
                  if (i != steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: i < activeStep
                            ? SportZoneTheme.primary
                            : SportZoneTheme.borderSubtle,
                      ),
                    ),
                ],
              ],
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 18,
                color: SportZoneTheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                _paymentLabel(order.paymentMethod),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SportZoneTheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                formatVnd(order.total),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _activeStepFor(String status) {
    switch (status) {
      case 'confirmed':
      case 'processing':
        return 1;
      case 'shipping':
        return 2;
      case 'delivered':
      case 'completed':
        return 3;
      case 'pending':
      default:
        return 0;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
      case 'processing':
        return 'Chờ lấy hàng';
      case 'shipping':
        return 'Chờ giao hàng';
      case 'delivered':
      case 'completed':
        return 'Đánh giá';
      case 'cancelled':
        return 'Đã hủy';
      case 'pending':
      default:
        return 'Chờ xác nhận';
    }
  }

  String _paymentLabel(String payment) {
    switch (payment) {
      case 'cod':
        return 'Thanh toán khi nhận hàng';
      case 'stripe':
        return 'Thẻ quốc tế (Stripe)';
      case 'bank_transfer':
        return 'Chuyển khoản';
      case 'e_wallet':
        return 'Ví điện tử';
      default:
        return payment.isEmpty ? 'Thanh toán' : payment;
    }
  }

  String _shortId(String id) =>
      id.length <= 8 ? id : id.substring(0, 8).toUpperCase();

  String _dateLabel(DateTime? value) {
    if (value == null) return 'Không rõ ngày tạo';
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}

class _StepNode extends StatelessWidget {
  final _OrderStep step;
  final bool active;
  final bool current;

  const _StepNode({
    required this.step,
    required this.active,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? SportZoneTheme.primary : SportZoneTheme.secondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: current ? 42 : 36,
          height: current ? 42 : 36,
          decoration: BoxDecoration(
            color: active
                ? SportZoneTheme.primary
                : SportZoneTheme.surfaceVariant,
            shape: BoxShape.circle,
            border: Border.all(
              color: active
                  ? SportZoneTheme.primary
                  : SportZoneTheme.borderSubtle,
              width: 2,
            ),
          ),
          child: Icon(
            step.icon,
            size: 19,
            color: active ? SportZoneTheme.onPrimary : SportZoneTheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          step.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: active ? FontWeight.w900 : FontWeight.w700,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _CancelledOrderNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SportZoneTheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Đơn hàng đã bị hủy.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: SportZoneTheme.error,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: SportZoneTheme.secondary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: SportZoneTheme.secondary),
            ),
            const SizedBox(height: 18),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _OrderStep {
  final String label;
  final IconData icon;

  const _OrderStep(this.label, this.icon);
}
