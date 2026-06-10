import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';


class NotificationItem {
  final String title;
  final String content;
  final String timeAgo;
  final String category;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.content,
    required this.timeAgo,
    required this.category,
    this.isRead = false,
  });
}

