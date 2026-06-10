import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';


class CartItem {
  final int id;
  final String productId;
  final String name;
  final int price;
  final String imageUrl;
  int quantity;
  final String size;
  final String color;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.size,
    required this.color,
  });

  CartItem.empty()
    : id = 0,
      productId = '',
      name = '',
      price = 0,
      imageUrl = '',
      quantity = 0,
      size = '',
      color = '';
}

