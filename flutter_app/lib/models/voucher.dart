class Voucher {
  final String id;
  final String code;
  final String? description;
  final String discountType; // 'percentage' | 'fixed_amount'
  final int discountValue;
  final int? maxDiscount;
  final int minOrderValue;
  final String targetTier;
  final int? usageLimit;
  final int usedCount;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final bool isActive;
  final bool isUsed; // User đã sử dụng chưa
  final DateTime? createdAt;

  Voucher({
    required this.id,
    required this.code,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.maxDiscount,
    this.minOrderValue = 0,
    required this.targetTier,
    this.usageLimit,
    this.usedCount = 0,
    this.startsAt,
    this.expiresAt,
    this.isActive = true,
    this.isUsed = false,
    this.createdAt,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: (json['voucherId'] ?? json['voucher_id'] ?? json['id'] ?? '').toString(),
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString(),
      discountType: (json['discountType'] ?? json['discount_type'] ?? 'fixed_amount').toString(),
      discountValue: _toInt(json['discountValue'] ?? json['discount_value']),
      maxDiscount: json['maxDiscount'] != null || json['max_discount'] != null
          ? _toInt(json['maxDiscount'] ?? json['max_discount'])
          : null,
      minOrderValue: _toInt(json['minOrderValue'] ?? json['min_order_value']),
      targetTier: (json['targetTier'] ?? json['target_tier'] ?? 'bronze').toString(),
      usageLimit: json['usageLimit'] != null || json['usage_limit'] != null
          ? _toInt(json['usageLimit'] ?? json['usage_limit'])
          : null,
      usedCount: _toInt(json['usedCount'] ?? json['used_count']),
      startsAt: DateTime.tryParse((json['startsAt'] ?? json['starts_at'] ?? '').toString()),
      expiresAt: DateTime.tryParse((json['expiresAt'] ?? json['expires_at'] ?? '').toString()),
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      isUsed: json['isUsed'] ?? json['is_used'] ?? false,
      createdAt: DateTime.tryParse((json['createdAt'] ?? json['created_at'] ?? '').toString()),
    );
  }

  String get discountDisplay {
    if (discountType == 'percentage') {
      final extra = maxDiscount != null ? ' (max ${_formatVnd(maxDiscount!)})' : '';
      return 'Giảm $discountValue%$extra';
    }
    return 'Giảm ${_formatVnd(discountValue)}';
  }

  String get tierDisplay {
    const map = {
      'bronze': 'Bronze 🥉',
      'silver': 'Silver 🥈',
      'gold': 'Gold 🥇',
      'platinum': 'Platinum 💎',
    };
    return map[targetTier] ?? targetTier;
  }

  /// Calculate the actual discount amount for a given subtotal
  int calculateDiscount(int subtotal) {
    if (subtotal < minOrderValue) return 0;
    if (discountType == 'percentage') {
      int amount = (subtotal * discountValue / 100).floor();
      if (maxDiscount != null) amount = amount < maxDiscount! ? amount : maxDiscount!;
      return amount < subtotal ? amount : subtotal;
    }
    return discountValue < subtotal ? discountValue : subtotal;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _formatVnd(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return '${buffer}đ';
  }
}
