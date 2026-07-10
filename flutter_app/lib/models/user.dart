class User {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatarUrl;
  final String membershipTier;
  final int totalSpent;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'customer',
    this.avatarUrl,
    this.membershipTier = 'bronze',
    this.totalSpent = 0,
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
      membershipTier:
          json['membership_tier']?.toString() ??
          json['membershipTier']?.toString() ??
          'bronze',
      totalSpent: _toInt(json['total_spent'] ?? json['totalSpent']),
    );
  }

  String get tierDisplay {
    const map = {
      'bronze': 'Bronze 🥉',
      'silver': 'Silver 🥈',
      'gold': 'Gold 🥇',
      'platinum': 'Platinum 💎',
    };
    return map[membershipTier] ?? membershipTier;
  }

  /// Ngưỡng bậc tiếp theo, null nếu đã Platinum
  int? get nextTierThreshold {
    const thresholds = {
      'bronze': 2000000,
      'silver': 5000000,
      'gold': 10000000,
    };
    return thresholds[membershipTier];
  }

  /// Bậc tiếp theo, null nếu đã Platinum
  String? get nextTierName {
    const next = {
      'bronze': 'Silver 🥈',
      'silver': 'Gold 🥇',
      'gold': 'Platinum 💎',
    };
    return next[membershipTier];
  }

  /// Progress từ 0.0 đến 1.0 tới bậc tiếp theo
  double get tierProgress {
    final next = nextTierThreshold;
    if (next == null) return 1.0;

    const currentThresholds = {
      'bronze': 0,
      'silver': 2000000,
      'gold': 5000000,
    };
    final current = currentThresholds[membershipTier] ?? 0;
    final range = next - current;
    if (range <= 0) return 1.0;
    final progress = (totalSpent - current) / range;
    return progress.clamp(0.0, 1.0);
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
