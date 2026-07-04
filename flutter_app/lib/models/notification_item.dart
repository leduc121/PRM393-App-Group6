class NotificationItem {
  final String? id;
  final String title;
  final String content;
  final String timeAgo;
  final String category;
  bool isRead;

  NotificationItem({
    this.id,
    required this.title,
    required this.content,
    required this.timeAgo,
    required this.category,
    this.isRead = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    return NotificationItem(
      id: json['notifId']?.toString(),
      title: json['title']?.toString() ?? 'Thông báo',
      content: (json['body'] ?? json['content'] ?? '').toString(),
      timeAgo: _relativeTime(createdAt),
      category: _categoryFromType(json['type']?.toString()),
      isRead: json['isRead'] == true || json['is_read'] == true,
    );
  }

  static String _categoryFromType(String? type) {
    return switch (type) {
      'order_confirmed' => 'ORDER',
      'order_shipping' => 'DELIVERY',
      'order_delivered' => 'DELIVERY',
      'order_cancelled' => 'ORDER',
      'promotion' => 'PROMO',
      'new_product' => 'PROMO',
      _ => 'SYSTEM',
    };
  }

  static String _relativeTime(DateTime? createdAt) {
    if (createdAt == null) return 'Vừa xong';
    final diff = DateTime.now().difference(createdAt.toLocal());
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${createdAt.day.toString().padLeft(2, '0')}/'
        '${createdAt.month.toString().padLeft(2, '0')}/'
        '${createdAt.year}';
  }
}
