class Order {
  final String id;
  final String status;
  final String paymentMethod;
  final int subtotal;
  final int shippingFee;
  final int discount;
  final int total;
  final DateTime? createdAt;
  
  // For Admin View
  final String? customerName;
  final String? customerPhone;

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
  });

  factory Order.fromJson(Map<String, dynamic> json) {
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
      customerName: json['address']?['recipientName'] ?? json['user']?['fullName'],
      customerPhone: json['address']?['phone'] ?? json['user']?['phone'],
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
