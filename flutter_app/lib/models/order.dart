class Order {
  final String id;
  final String status;
  final String paymentMethod;
  final int subtotal;
  final int shippingFee;
  final int discount;
  final int total;
  final DateTime? createdAt;

  // For Admin View Detail
  final String? customerName;
  final String? customerPhone;
  final String? userFullName;
  final String? userEmail;
  final String? userPhone;
  final String? recipientName;
  final String? recipientPhone;
  final String? fullAddress;

  Order({
    required this.id,
    required this.status,
    required this.paymentMethod,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.total,
    this.createdAt,
    this.customerName,
    this.customerPhone,
    this.userFullName,
    this.userEmail,
    this.userPhone,
    this.recipientName,
    this.recipientPhone,
    this.fullAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final addressJson = json['address'] as Map<String, dynamic>?;
    final userJson = json['user'] as Map<String, dynamic>?;

    String? fullAddr;
    if (addressJson != null) {
      final street = addressJson['street']?.toString() ?? '';
      final ward = addressJson['ward']?.toString() ?? '';
      final district = addressJson['district']?.toString() ?? '';
      final city = addressJson['city']?.toString() ?? '';
      final parts = [street, ward, district, city].where((p) => p.isNotEmpty);
      fullAddr = parts.isNotEmpty ? parts.join(', ') : null;
    }

    return Order(
      id: (json['orderId'] ?? json['order_id'] ?? json['id'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      paymentMethod: (json['paymentMethod'] ?? json['payment_method'] ?? '')
          .toString(),
      subtotal: _toInt(json['subtotal']),
      shippingFee: _toInt(json['shippingFee'] ?? json['shipping_fee']),
      discount: _toInt(json['discount']),
      total: _toInt(json['total']),
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? json['created_at'] ?? '').toString(),
      ),
      customerName: (addressJson?['recipientName'] ?? userJson?['fullName'])
          ?.toString(),
      customerPhone: (addressJson?['phone'] ?? userJson?['phone'])?.toString(),
      userFullName: userJson?['fullName']?.toString(),
      userEmail: userJson?['email']?.toString(),
      userPhone: userJson?['phone']?.toString(),
      recipientName: addressJson?['recipientName']?.toString(),
      recipientPhone: addressJson?['phone']?.toString(),
      fullAddress: fullAddr,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
