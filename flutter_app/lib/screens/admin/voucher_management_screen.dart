import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';
import 'package:intl/intl.dart';

class VoucherManagementScreen extends StatefulWidget {
  const VoucherManagementScreen({super.key});

  @override
  State<VoucherManagementScreen> createState() => _VoucherManagementScreenState();
}

class _VoucherManagementScreenState extends State<VoucherManagementScreen> {
  List<Voucher> _vouchers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchVouchers();
    });
  }

  Future<void> _fetchVouchers() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getAllVouchers();
    if (result.isSuccess && result.data is List) {
      setState(() {
        _vouchers = (result.data as List)
            .whereType<Map<String, dynamic>>()
            .map((json) => Voucher.fromJson(json))
            .toList();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.errorMessage ?? 'Lỗi tải danh sách voucher')),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _deleteVoucher(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa voucher này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: SportZoneTheme.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final result = await ApiService.deleteVoucher(id);
    if (result.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa voucher thành công')),
        );
      }
      _fetchVouchers();
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.errorMessage ?? 'Lỗi xóa voucher')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      appBar: AppBar(
        title: const Text('Quản lý Vouchers', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: SportZoneTheme.surface,
        foregroundColor: SportZoneTheme.primary,
        elevation: 1,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: SportZoneTheme.primary,
        onPressed: () async {
          final res = await Navigator.pushNamed(context, '/admin/vouchers/form');
          if (res == true) _fetchVouchers();
        },
        child: const Icon(Icons.add, color: SportZoneTheme.onPrimary),
      ),
      body: _isLoading && _vouchers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _vouchers.isEmpty
              ? const Center(child: Text('Chưa có voucher nào.'))
              : RefreshIndicator(
                  onRefresh: _fetchVouchers,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _vouchers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final voucher = _vouchers[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: SportZoneTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Color(0x10000000), blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  voucher.code,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20, color: SportZoneTheme.secondary),
                                      onPressed: () async {
                                        final res = await Navigator.pushNamed(
                                          context,
                                          '/admin/vouchers/form',
                                          arguments: voucher,
                                        );
                                        if (res == true) _fetchVouchers();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20, color: SportZoneTheme.error),
                                      onPressed: () => _deleteVoucher(voucher.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              voucher.discountDisplay,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00C853),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Hạng áp dụng: ${voucher.tierDisplay}'),
                            Text('Đơn tối thiểu: ${formatVnd(voucher.minOrderValue)}'),
                            if (voucher.usageLimit != null)
                              Text('Lượt dùng: ${voucher.usedCount} / ${voucher.usageLimit}'),
                            if (voucher.expiresAt != null)
                              Text('Hết hạn: ${DateFormat('dd/MM/yyyy HH:mm').format(voucher.expiresAt!)}',
                                  style: TextStyle(color: voucher.expiresAt!.isBefore(DateTime.now()) ? SportZoneTheme.error : null)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: voucher.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                voucher.isActive ? 'ĐANG HOẠT ĐỘNG' : 'ĐÃ TẮT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: voucher.isActive ? Colors.green : Colors.red,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
