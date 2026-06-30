import 'package:flutter/material.dart';
import 'package:flutter_app/core.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  bool _isLoading = true;
  String _error = '';
  List<Order> _allOrders = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final result = await ApiService.getAllOrders();
    if (result.isSuccess) {
      final raw = result.data;
      final list = raw is List ? raw : <dynamic>[];
      setState(() {
        _allOrders = list
            .whereType<Map<String, dynamic>>()
            .map(Order.fromJson)
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result.errorMessage ?? 'Không thể tải danh sách đơn hàng';
        _isLoading = false;
      });
    }
  }

  void _onStatusUpdated(String orderId, String newStatus) {
    setState(() {
      final index = _allOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        final old = _allOrders[index];
        _allOrders[index] = Order(
          id: old.id,
          status: newStatus,
          paymentMethod: old.paymentMethod,
          subtotal: old.subtotal,
          shippingFee: old.shippingFee,
          discount: old.discount,
          total: old.total,
          createdAt: old.createdAt,
          customerName: old.customerName,
          customerPhone: old.customerPhone,
        );
      }
    });
  }

  List<Order> get _filteredOrders {
    if (_searchQuery.isEmpty) return _allOrders;
    final lowerQ = _searchQuery.toLowerCase();
    return _allOrders.where((o) {
      final matchId = o.id.toLowerCase().contains(lowerQ);
      final matchName = (o.customerName ?? '').toLowerCase().contains(lowerQ);
      final matchPhone = (o.customerPhone ?? '').toLowerCase().contains(lowerQ);
      return matchId || matchName || matchPhone;
    }).toList();
  }

  List<Order> _getOrdersByTab(int index) {
    final list = _filteredOrders;
    switch (index) {
      case 0: // Tất cả
        return list;
      case 1: // Cần xử lý
        return list
            .where((o) => o.status == 'pending' || o.status == 'confirmed')
            .toList();
      case 2: // Đang giao
        return list
            .where((o) => o.status == 'processing' || o.status == 'shipping')
            .toList();
      case 3: // Hoàn tất
        return list
            .where((o) => o.status == 'delivered' || o.status == 'completed')
            .toList();
      case 4: // Đã huỷ
        return list.where((o) => o.status == 'cancelled').toList();
      default:
        return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: SportZoneTheme.background,
        appBar: AppBar(
          backgroundColor: SportZoneTheme.surface,
          foregroundColor: SportZoneTheme.primary,
          elevation: 0,
          title: const Text(
            'Quản lý Đơn hàng',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: SportZoneTheme.primary,
            unselectedLabelColor: SportZoneTheme.secondary,
            indicatorColor: SportZoneTheme.primary,
            tabs: [
              Tab(text: 'Tất cả'),
              Tab(text: 'Cần xử lý'),
              Tab(text: 'Đang giao'),
              Tab(text: 'Hoàn tất'),
              Tab(text: 'Đã huỷ'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              color: SportZoneTheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm theo Tên, SĐT, Mã đơn...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: SportZoneTheme.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error,
                                  style: const TextStyle(color: Colors.red)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _fetchOrders,
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        )
                      : TabBarView(
                          children: List.generate(5, (index) {
                            final orders = _getOrdersByTab(index);
                            return RefreshIndicator(
                              onRefresh: _fetchOrders,
                              child: orders.isEmpty
                                  ? ListView(
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.all(32),
                                          child: Center(
                                            child: Text('Không có đơn hàng nào.'),
                                          ),
                                        ),
                                      ],
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: orders.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 12),
                                      itemBuilder: (_, i) => _AdminOrderCard(
                                        order: orders[i],
                                        onUpdated: _onStatusUpdated,
                                      ),
                                    ),
                            );
                          }),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final Order order;
  final void Function(String orderId, String newStatus) onUpdated;

  const _AdminOrderCard({required this.order, required this.onUpdated});

  @override
  Widget build(BuildContext context) {
    final cancelled = order.status == 'cancelled';

    return Container(
      decoration: BoxDecoration(
        color: SportZoneTheme.surface,
        borderRadius: BorderRadius.circular(12),
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
              InkWell(
                onTap: () => _showStatusEditor(context),
                borderRadius: BorderRadius.circular(999),
                child: Container(
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _statusLabel(order.status),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: cancelled
                                  ? SportZoneTheme.error
                                  : SportZoneTheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.edit,
                        size: 14,
                        color: cancelled
                            ? SportZoneTheme.error
                            : SportZoneTheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 16, color: SportZoneTheme.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.customerName ?? 'Khách hàng',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone_outlined,
                  size: 16, color: SportZoneTheme.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.customerPhone ?? 'Chưa có SĐT',
                  style: const TextStyle(color: SportZoneTheme.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng thanh toán:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SportZoneTheme.secondary,
                    ),
              ),
              Text(
                formatVnd(order.total),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: SportZoneTheme.primary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStatusEditor(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Material(
              color: SportZoneTheme.surface,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Text(
                        'Cập nhật trạng thái',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: SportZoneTheme.primary,
                        ),
                      ),
                    ),
                    const Divider(),
                    _StatusOption(
                      label: 'Chờ xác nhận (pending)',
                      value: 'pending',
                      current: order.status,
                      onTap: () => _update(context, sheetContext, 'pending'),
                    ),
                    _StatusOption(
                      label: 'Đã xác nhận (confirmed)',
                      value: 'confirmed',
                      current: order.status,
                      onTap: () => _update(context, sheetContext, 'confirmed'),
                    ),
                    _StatusOption(
                      label: 'Đang chuẩn bị (processing)',
                      value: 'processing',
                      current: order.status,
                      onTap: () => _update(context, sheetContext, 'processing'),
                    ),
                    _StatusOption(
                      label: 'Đang giao hàng (shipping)',
                      value: 'shipping',
                      current: order.status,
                      onTap: () => _update(context, sheetContext, 'shipping'),
                    ),
                    _StatusOption(
                      label: 'Đã giao (delivered)',
                      value: 'delivered',
                      current: order.status,
                      onTap: () => _update(context, sheetContext, 'delivered'),
                    ),
                    _StatusOption(
                      label: 'Hoàn tất (completed)',
                      value: 'completed',
                      current: order.status,
                      onTap: () => _update(context, sheetContext, 'completed'),
                    ),
                    _StatusOption(
                      label: 'Đã huỷ (cancelled)',
                      value: 'cancelled',
                      current: order.status,
                      isError: true,
                      onTap: () => _update(context, sheetContext, 'cancelled'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _update(
      BuildContext context, BuildContext sheetContext, String newStatus) async {
    Navigator.pop(sheetContext);
    if (newStatus == order.status) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final res = await ApiService.updateOrderStatus(order.id, newStatus);
    if (context.mounted) Navigator.pop(context); // pop loading

    if (res.isSuccess) {
      onUpdated(order.id, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thành công!')),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.errorMessage ?? 'Có lỗi xảy ra')),
        );
      }
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Đã xác nhận';
      case 'processing':
        return 'Đang chuẩn bị';
      case 'shipping':
        return 'Đang giao hàng';
      case 'delivered':
        return 'Đã giao';
      case 'completed':
        return 'Hoàn tất';
      case 'cancelled':
        return 'Đã hủy';
      case 'pending':
      default:
        return 'Chờ xác nhận';
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

class _StatusOption extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final bool isError;
  final VoidCallback onTap;

  const _StatusOption({
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == current;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        color: isSelected ? SportZoneTheme.electricLime.withValues(alpha: 0.2) : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: isError
                      ? SportZoneTheme.error
                      : (isSelected ? SportZoneTheme.primary : SportZoneTheme.secondary),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: SportZoneTheme.primary),
          ],
        ),
      ),
    );
  }
}
