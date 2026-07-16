class ProductVariant {
  final String id;
  final String productId;
  final String size;
  final String colorName;
  final int stockQty;
  final String? imageUrl;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.size,
    required this.colorName,
    required this.stockQty,
    this.imageUrl,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    final rawStock = json['stockQty'] ?? json['stock_qty'] ?? 0;
    return ProductVariant(
      id:
          json['variantId']?.toString() ??
          json['variant_id']?.toString() ??
          json['id']?.toString() ??
          '',
      productId:
          json['productId']?.toString() ?? json['product_id']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      colorName:
          json['colorName']?.toString() ?? json['color_name']?.toString() ?? '',
      stockQty: rawStock is num
          ? rawStock.toInt()
          : int.tryParse(rawStock.toString()) ?? 0,
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString(),
    );
  }
}
