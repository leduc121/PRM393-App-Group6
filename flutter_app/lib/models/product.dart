import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';


class Product {
  final String id;
  final String brand;
  final String name;
  final int price;
  final int? originalPrice;
  final String? discount;
  final String imageUrl;
  final String category;
  final String description;
  final String? brandId;
  final String? categoryId;
  final List<String> images;
  final String? material;
  final String? gender;
  final String? origin;
  final String? warrantyInfo;
  final int totalStock;

  Product({
    required this.id,
    required this.brand,
    required this.name,
    required this.price,
    this.originalPrice,
    this.discount,
    required this.imageUrl,
    required this.category,
    required this.description,
    this.brandId,
    this.categoryId,
    this.images = const [],
    this.material,
    this.gender,
    this.origin,
    this.warrantyInfo,
    this.totalStock = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] is String)
        ? int.tryParse(json['price']) ?? 0
        : (json['price'] as num?)?.toInt() ?? 0;
    final salePrice = json['salePrice'] != null
        ? (json['salePrice'] is String
              ? int.tryParse(json['salePrice'])
              : (json['salePrice'] as num?)?.toInt())
        : null;

    // Determine display price and original price
    final displayPrice = salePrice ?? price;
    final origPrice = salePrice != null ? price : null;

    // Calculate discount badge
    String? discountBadge;
    if (origPrice != null && origPrice > displayPrice) {
      final pct = ((origPrice - displayPrice) / origPrice * 100).round();
      discountBadge = '-$pct%';
    }

    // Get brand name
    final brandData = json['brand'];
    final brandName = brandData is Map
        ? (brandData['name']?.toString() ?? '')
        : '';

    // Get category name
    final catData = json['category'];
    final catName = catData is Map ? (catData['name']?.toString() ?? '') : '';

    // Get images
    final imagesList = <String>[];
    if (json['images'] is List) {
      for (var img in json['images']) {
        imagesList.add(img.toString());
      }
    }

    final firstImage = imagesList.isNotEmpty
        ? imagesList.first
        : 'https://via.placeholder.com/300x300?text=No+Image';

    return Product(
      id: json['productId']?.toString() ?? json['id']?.toString() ?? '',
      brand: brandName,
      name: json['name']?.toString() ?? '',
      price: displayPrice,
      originalPrice: origPrice,
      discount: discountBadge,
      imageUrl: firstImage,
      category: catName,
      description: json['description']?.toString() ?? '',
      brandId: json['brandId']?.toString(),
      categoryId: json['categoryId']?.toString(),
      images: imagesList,
      material: json['material']?.toString(),
      gender: json['gender']?.toString(),
      origin: json['origin']?.toString(),
      warrantyInfo: json['warrantyInfo']?.toString() ?? json['warranty_info']?.toString(),
      totalStock: (json['totalStock'] as num?)?.toInt() ?? 0,
    );
  }
}

final productList = <Product>[
  Product(
    id: 'pegasus_40',
    brand: 'NIKE',
    name: 'Giày Chạy Bộ Pegasus 40',
    price: 2800000,
    originalPrice: 3200000,
    discount: '-15%',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAPgZ35z3CkEwvbqr8k-JquljTF6IpGzOVENVsBz2K8tZ-B8ofcobg7F_hh14anJPHDkt3OWD5MosD_hXAqHeSaIkzJABizi6_KrbJnTjLkWTW4fw6IzNF1MkCurRALk0I4R_lTZ7AJualyOuLk6iUV152L7cSCtvzknNTWb28ebTMOODtIqhTMhm_MrmXfMVJu_-pOCD8QN5c2dyD3uSf6OZbWPVb2SXgbZmI-jmRNys_iTW_Kmkce-mCoTP52n8mc15IBmneoiiw',
    category: 'Giày',
    description:
        'Dòng giày chạy huyền thoại thế hệ thứ 40 từ Nike. Trực quan cấu trúc đệm Air Zoom đàn hồi, phân bố lực cực tốt giúp tối ưu hóa hiệu suất chạy bộ hàng ngày của bạn.',
  ),
  Product(
    id: 'adidas_jersey',
    brand: 'ADIDAS',
    name: 'Áo Đấu Sân Nhà 23/24',
    price: 1950000,
    discount: 'NEW',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAiaFXI5Cxb_0GKnscXnYic8wbcSO0VG4wPll3F-gFMrCYYYP1Q2ldcvN17oRLM8eRafaOKa2uylBn9s7cP_JqG5gEGk2c7QS4mEPXgeax9ogtvIoGO9VzaZGYQMa3gs9ewxGVAbXtMTmwTvctbQXjC8U3SKIeC3EK184IUqx2mzYkH9v8ZYfGyb4kroPxGe-r2gOTaXFxTPms-ZHwFvRJ7j9NRrZudM34Be7jg7cw9t8rjl2WXpH2CiXnOilk6DlwuZT8Os7LO64E',
    category: 'Áo',
    description:
        'Áo đấu sân nhà chính thức mùa giải 23/24 với chất liệu poly cao cấp thoáng mát, thoát mồ hôi tối ưu Aeroready giúp giữ cơ thể luôn khô ráo.',
  ),
  Product(
    id: 'puma_nitro',
    brand: 'PUMA',
    name: 'Giày Nitro Elite v2',
    price: 3120000,
    originalPrice: 3900000,
    discount: '-20%',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuClw8SeBc7ybQWos4zhQhwpAHWCH6cH79uq51FeDAOWGacbU38SgXZx7GYzyAmZivittK9IXVwWUTlfVApz4jHMCbH00LmazEFqNZ-PAUpB7lFqCu3ZFLhcfeyl-vX1yzRtjfQWK-FvqX7PGvY50ask2GjwitTwZ5jhUVi-k300xIa1uwe3ftgq9yjmgZSROLU_h_dfL6IgSbriJ7ZfSyANa44VP9Nk-1ZvOjm1q0iu5RobJq8HySRqru_4rgcwujSeuN977TbbhP4',
    category: 'Giày',
    description:
        'Thiết kế tương lai với bọt Nitro Elite phản lực siêu nhẹ. Tấm carbon chạy dọc đế giày hỗ trợ định hướng sải chân lực đẩy mạnh mẽ hơn.',
  ),
  Product(
    id: 'ua_shorts',
    brand: 'UNDER ARMOUR',
    name: 'Quần Short Chạy Bộ Pro',
    price: 850000,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCcDbqg7_acURvQe-3zwJXfHED3injZq8T6fYgwf_S23DqF2XbEpnvt7gm5vkaXj2HOyLUrZWjFwg5bz1z3zxzuQatiQmyT1lDKlYbEekm21dzMaxeiHXOnPlXD_x7rSBedhpwegWwFS2OYndPqbAdWWMOwehD99e69CqiTKnfA_W35qCLsetEVxBV8jU9NaBwr_u7mPjBZlSOpFVAKJD42nYisRlQzWoyxx9HrkBQQhBc6KCQTo726TWXv2J8XqKRRyGuZX1w9GJA',
    category: 'Quần',
    description:
        'Chất liệu siêu nhẹ co giãn 4 chiều mang đến dải chuyển động linh hoạt. Thắt lưng chun bản rộng siêu êm dễ điều chỉnh độ ôm.',
  ),
  Product(
    id: 'nike_air_zoom',
    brand: 'NIKE',
    name: 'Giày Chạy Bộ Nike Air Zoom',
    price: 3500000,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBiSz7-RpWpLuDEm1r56jSDqwAfxU_YumkO7qlQ8RBCnfhz84nCaf2i-ZsU53I7L7DSFkGcgRjaADsFmZFBSvch7CVsNKCZG_WgHqKryRZI866C0lSRqnvio04KC7x8N1Yz6NbaKR5h59y-UarxyUPt3CVM8ltOlWfm_pn_W6_Ssoeel4l3lIVvXePVg8kWxuDz1yn4e9i2bQoZYnFHnVoxR5NIln9RRePQjgooUmsCz8hgILRHZfVURCxguHWoRriOw-tD--hlsDg',
    category: 'Giày',
    description:
        'Được tối ưu hóa hoàn hảo với cấu trúc dệt Mesh tối tân và khối đệm Zoom Air phản hồi đỉnh cao, là lựa chọn số một cho tập luyện cường độ lớn.',
  ),
  Product(
    id: 'nike_air_max_270',
    brand: 'NIKE',
    name: 'Nike Air Max 270',
    price: 3450000,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDwjMhxELTWXCnRihkjjM1NTRAKElB0-G4V3tDZEOF5YDwxSrtqkQ2nM4TSjTUk1JVpWQw3lX1kpuhJQgnp-KhWsJ1BrcrJXO4YtMr7ZeiSnjUiKAkIa4tDAJ7OxElb8z45651q9j9Gsjk2_haEV8JOYKaDVD5wNr0ze6rtO0oHpayV5zARbohE0OVrLiz-kHqLGo76pPXQM_yhYNRQMpKTYsSrA5TU49vcFRBzYW29UyMFb61MMd8Z_E2WHfYZFitGa1jO4jrcvrY',
    category: 'Giày',
    description:
        'Phiên bản phong cách thời thượng với bong bóng đệm gót Air Max cao 270 độ siêu êm ái, mang lại chất thời trang đặc tả thương hiệu Nike.',
  ),
  Product(
    id: 'drifit_tee',
    brand: 'NIKE',
    name: 'Dri-FIT Adv Tee',
    price: 850000,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBNsAVhdXDzMjSFUsOGwXoVcurcTCD0DoHyZbUL4atVjxIu9WPq4fw8qTA1KhYJZDVpR-r9BNLAIJ10M8qYPC1sr08Ctlp20zLW1jTxzLA39li3SCSHagoCoWIW1Nh-pOMYM6FwqMdB6uwMD00PAQX2CZ2YouG3vayy507-5w7-VhEuJvbI9dz9OubjUTknV-mc5E6Dq7zG2elMYfSVDApuRhgYgUzmmYHOUe1rh9Sxuo6EuDCFu3Ns7irA7FU6IIvREXJg_Ll978Q',
    category: 'Áo',
    description:
        'Dòng áo dệt công nghệ thơi trang cao cấp chuyên sâu, sấy khô thông gió thoáng ở những vùng ra nhiều nhiệt chính trên cơ thể.',
  ),
  Product(
    id: 'nike_dunk_low',
    brand: 'NIKE',
    name: 'Nike Dunk Low Retro',
    price: 2990000,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAgjahdof8HWdDvif-Ci0fVoM1bIjYof_ZZb143kAaot8H7BWbItYPT90WOvFmendFdRAP0BVgx1JPj8P7TBxfYHzL8ugv7kzscsbVYXutG-KmGrs_bHPAVKbjr8sj9vRR3bJDpYa8wNlm0X-7Zj7J_cj6cveg3G0ARWgiLFPuo472HRl7lsdllLbaO0LUG5J2WjZJzTr76HQfvx6TTMYwMuBfRMynAdZHUaIA--7dnR3b3PE7xZ47HrtADNdDuoBmnuUiVmEURv8w',
    category: 'Giày',
    description:
        'Huyền thoại bóng rổ thập niên 80 chuyển mình thành biểu tượng văn hóa sát ván đường phố. Thiết kế chất da xịn bóng bẩy, thanh lịch.',
  ),
];
