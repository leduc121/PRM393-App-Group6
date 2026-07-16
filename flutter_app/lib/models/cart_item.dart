class CartItem {
  final String id;
  final String productId;
  final String name;
  final int price;
  final String imageUrl;
  int quantity;
  final String size;
  final String color;
  final String variantId;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.size,
    required this.color,
    required this.variantId,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};
    final variant = json['variant'] as Map<String, dynamic>? ?? {};
    final images = product['images'] as List<dynamic>? ?? [];
    final imgUrl = images.isNotEmpty
        ? images.first.toString()
        : 'https://via.placeholder.com/300x300?text=No+Image';

    return CartItem(
      id: json['itemId']?.toString() ?? '',
      productId: product['productId']?.toString() ?? '',
      name: product['name']?.toString() ?? '',
      price: (json['unitPrice'] as num?)?.toInt() ?? 0,
      imageUrl: imgUrl,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      size: variant['size']?.toString() ?? '',
      color: variant['colorName']?.toString() ?? '',
      variantId: variant['variantId']?.toString() ?? '',
    );
  }

  CartItem.empty()
    : id = '',
      productId = '',
      name = '',
      price = 0,
      imageUrl = '',
      quantity = 0,
      size = '',
      color = '',
      variantId = '';
}
