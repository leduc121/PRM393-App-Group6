import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';


class Brand {
  final String brandId;
  final String name;
  final String? logoUrl;
  final String? country;

  Brand({
    required this.brandId,
    required this.name,
    this.logoUrl,
    this.country,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      brandId: json['brandId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString(),
      country: json['country']?.toString(),
    );
  }
}

