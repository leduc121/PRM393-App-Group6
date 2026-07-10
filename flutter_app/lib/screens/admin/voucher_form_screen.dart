import 'package:flutter/material.dart';
import 'package:flutter_app/core.dart';

class VoucherFormScreen extends StatefulWidget {
  final Voucher? voucher;
  const VoucherFormScreen({super.key, this.voucher});

  @override
  State<VoucherFormScreen> createState() => _VoucherFormScreenState();
}

class _VoucherFormScreenState extends State<VoucherFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _maxDiscountCtrl = TextEditingController();
  final _minOrderCtrl = TextEditingController();
  final _usageLimitCtrl = TextEditingController();

  String _discountType = 'fixed_amount';
  String _targetTier = 'bronze';
  bool _isActive = true;
  bool _isLoading = false;
  DateTime? _expiresAt;

  @override
  void initState() {
    super.initState();
    if (widget.voucher != null) {
      final v = widget.voucher!;
      _codeCtrl.text = v.code;
      _descCtrl.text = v.description ?? '';
      _discountType = v.discountType;
      _valueCtrl.text = v.discountValue.toString();
      _maxDiscountCtrl.text = v.maxDiscount?.toString() ?? '';
      _minOrderCtrl.text = v.minOrderValue.toString();
      _usageLimitCtrl.text = v.usageLimit?.toString() ?? '';
      _targetTier = v.targetTier;
      _isActive = v.isActive;
      _expiresAt = v.expiresAt;
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _valueCtrl.dispose();
    _maxDiscountCtrl.dispose();
    _minOrderCtrl.dispose();
    _usageLimitCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = <String, dynamic>{
      'code': _codeCtrl.text.trim(),
      'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      'discountType': _discountType,
      'discountValue': int.parse(_valueCtrl.text.trim()),
      'maxDiscount': _maxDiscountCtrl.text.trim().isEmpty ? null : int.parse(_maxDiscountCtrl.text.trim()),
      'minOrderValue': _minOrderCtrl.text.trim().isEmpty ? 0 : int.parse(_minOrderCtrl.text.trim()),
      'targetTier': _targetTier,
      'usageLimit': _usageLimitCtrl.text.trim().isEmpty ? null : int.parse(_usageLimitCtrl.text.trim()),
      'isActive': _isActive,
      'expiresAt': _expiresAt?.toIso8601String(),
    };

    ApiResult result;
    if (widget.voucher == null) {
      result = await ApiService.createVoucher(data);
    } else {
      result = await ApiService.updateVoucher(widget.voucher!.id, data);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lưu voucher thành công')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.errorMessage ?? 'Lưu voucher thất bại')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.voucher != null;
    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa Voucher' : 'Thêm Voucher', style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: SportZoneTheme.surface,
        foregroundColor: SportZoneTheme.primary,
        elevation: 1,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _codeCtrl,
              decoration: const InputDecoration(labelText: 'Mã Voucher (Code)'),
              validator: (val) => val == null || val.trim().isEmpty ? 'Bắt buộc' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Mô tả (không bắt buộc)'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _discountType,
              decoration: const InputDecoration(labelText: 'Loại giảm giá'),
              items: const [
                DropdownMenuItem(value: 'fixed_amount', child: Text('Giảm số tiền cố định')),
                DropdownMenuItem(value: 'percentage', child: Text('Giảm theo phần trăm (%)')),
              ],
              onChanged: (v) => setState(() => _discountType = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _valueCtrl,
              decoration: InputDecoration(labelText: _discountType == 'percentage' ? 'Phần trăm giảm (VD: 10)' : 'Số tiền giảm (VD: 50000)'),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Bắt buộc';
                if (int.tryParse(val) == null) return 'Phải là số nguyên';
                return null;
              },
            ),
            if (_discountType == 'percentage') ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _maxDiscountCtrl,
                decoration: const InputDecoration(labelText: 'Số tiền giảm tối đa (Tùy chọn)'),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _minOrderCtrl,
              decoration: const InputDecoration(labelText: 'Giá trị đơn tối thiểu (VD: 200000)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _targetTier,
              decoration: const InputDecoration(labelText: 'Hạng thành viên áp dụng'),
              items: const [
                DropdownMenuItem(value: 'bronze', child: Text('Bronze (Mọi thành viên)')),
                DropdownMenuItem(value: 'silver', child: Text('Từ Silver trở lên')),
                DropdownMenuItem(value: 'gold', child: Text('Từ Gold trở lên')),
                DropdownMenuItem(value: 'platinum', child: Text('Chỉ Platinum')),
              ],
              onChanged: (v) => setState(() => _targetTier = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _usageLimitCtrl,
              decoration: const InputDecoration(labelText: 'Giới hạn số lần dùng chung (Tùy chọn)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _expiresAt ?? DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_expiresAt ?? DateTime.now()),
                  );
                  if (time != null) {
                    setState(() {
                      _expiresAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                    });
                  }
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Ngày hết hạn (Tùy chọn)',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _expiresAt != null
                      ? '${_expiresAt!.day.toString().padLeft(2, '0')}/${_expiresAt!.month.toString().padLeft(2, '0')}/${_expiresAt!.year} ${_expiresAt!.hour.toString().padLeft(2, '0')}:${_expiresAt!.minute.toString().padLeft(2, '0')}'
                      : 'Không giới hạn thời gian',
                  style: TextStyle(color: _expiresAt != null ? Colors.black87 : Colors.black54),
                ),
              ),
            ),
            if (_expiresAt != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _expiresAt = null),
                  child: const Text('Bỏ ngày hết hạn', style: TextStyle(color: SportZoneTheme.error)),
                ),
              ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Kích hoạt voucher này ngay'),
              value: _isActive,
              activeColor: SportZoneTheme.primary,
              onChanged: (v) => setState(() => _isActive = v),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SportZoneTheme.primary,
                  foregroundColor: SportZoneTheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('LƯU VOUCHER', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
