import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';


class User {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatarUrl;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'customer',
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid']?.toString() ?? '',
      name: json['full_name']?.toString() ?? json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'customer',
      avatarUrl:
          json['avatar_url']?.toString() ?? json['avatarUrl']?.toString(),
    );
  }
}

