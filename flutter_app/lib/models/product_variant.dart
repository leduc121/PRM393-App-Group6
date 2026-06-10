class ProductVariant {
  final String id;
  final String productId;
  final String size;
  final String colorName;
  final int stockQty;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.size,
    required this.colorName,
    required this.stockQty,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['variantId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      colorName: json['colorName']?.toString() ?? json['color_name']?.toString() ?? '',
      stockQty: (json['stockQty'] ?? json['stock_qty'] as num?)?.toInt() ?? 0,
    );
  }
}
