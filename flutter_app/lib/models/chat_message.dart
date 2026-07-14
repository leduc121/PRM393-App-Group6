import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';


class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final bool isRead;
  final DateTime? sentAt;

  ChatMessage({
    this.id = '',
    required this.message,
    required this.isUser,
    this.isRead = false,
    this.sentAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, {required bool isCurrentUserAdmin}) {
    final role = json['senderRole'] ?? json['sender_role'] ?? '';
    final isCustomer = role == 'customer';
    
    return ChatMessage(
      id: json['msgId'] ?? json['msg_id'] ?? '',
      message: json['content'] ?? '',
      isUser: isCurrentUserAdmin ? !isCustomer : isCustomer,
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      sentAt: () {
        final dateStr = (json['sentAt'] ?? json['sent_at'])?.toString();
        if (dateStr == null) return null;
        DateTime? dt = DateTime.tryParse(dateStr);
        if (dt != null && !dt.isUtc && !dateStr.endsWith('Z') && !dateStr.contains('+') && !dateStr.contains('-')) {
          dt = DateTime.tryParse('${dateStr}Z');
        }
        return dt?.toLocal();
      }(),
    );
  }
}

