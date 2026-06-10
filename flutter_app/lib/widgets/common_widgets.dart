import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';

class BadgeBubble extends StatelessWidget {
  final String text;
  const BadgeBubble(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: SportZoneTheme.electricLime,
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: SportZoneTheme.primary,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AccordionItemState extends State<AccordionItem> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => expanded = !expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                Icon(expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              widget.content,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: SportZoneTheme.secondary),
            ),
          ),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        const Divider(color: SportZoneTheme.borderSubtle),
      ],
    );
  }
}

class AccordionItem extends StatefulWidget {
  final String title;
  final String content;
  const AccordionItem({required this.title, required this.content, super.key});

  @override
  State<AccordionItem> createState() => _AccordionItemState();
}

class BadgeTag extends StatelessWidget {
  final String text;
  final bool isAccent;
  const BadgeTag({required this.text, required this.isAccent, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAccent ? SportZoneTheme.electricLime : SportZoneTheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isAccent ? SportZoneTheme.primary : SportZoneTheme.onPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    final unreadCount = state.notifications
        .where((item) => !item.isRead)
        .length;
    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: SportZoneTheme.primary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  Text(
                    'THÔNG BÁO',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: SportZoneTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unreadCount MỚI',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: SportZoneTheme.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SportZoneTheme.surface,
                  foregroundColor: SportZoneTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  side: const BorderSide(
                    color: SportZoneTheme.primary,
                    width: 1.5,
                  ),
                ),
                onPressed: state.markAllNotificationsRead,
                child: Text(
                  'ĐÁNH DẤU TẤT CẢ LÀ ĐÃ ĐỌC',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: state.notifications.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.notifications.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: SportZoneTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuBsRNg5USYDRHIBxye5vzURNc61PCkEyDNyC2-FlTtL9_3deNbAwpHw6Ty7GROg631dZWdDK_QveVq95P9OUtdvzXWjUknf3Sp2MO7vKIr3-4Ca2YleYi45MED1IDDoTvoomEpix0gL0egG-STYmFYCYZ9d6MhkoSDtCiYDMqj0WJgmQVZn0U_faA_s51xbvpNl1mbwQKbtPwQq8zhNABuqtv_rG9K-bUrDLHzK-xjytwSTx0A22snSH6cGMiayLtN6oIp-MZd6vt4',
                                width: double.infinity,
                                height: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'KEEP GRINDING',
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    color: SportZoneTheme.onPrimary,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Đừng để các thông báo lỡ nhịp tập luyện của bạn. Cập nhật mẫu drops mới nhất ngay.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final item = state.notifications[index];
                  return Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: item.isRead
                              ? SportZoneTheme.surface
                              : SportZoneTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: SportZoneTheme.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item.category == 'DELIVERY'
                                    ? Icons.local_shipping
                                    : item.category == 'PROMO'
                                    ? Icons.confirmation_number
                                    : Icons.sell,
                                color: SportZoneTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (!item.isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: SportZoneTheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      if (!item.isRead)
                                        const SizedBox(width: 8),
                                      Text(
                                        item.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: item.isRead
                                                  ? SportZoneTheme.secondary
                                                  : SportZoneTheme.primary,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.content,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: SportZoneTheme.secondary,
                                          height: 1.4,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.timeAgo,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: const Color.fromRGBO(
                                            93,
                                            95,
                                            95,
                                            0.7,
                                          ),
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (!item.isRead)
                              Container(
                                width: 4,
                                height: 44,
                                color: SportZoneTheme.electricLime,
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentOption {
  final String code;
  final String label;
  final IconData icon;
  const PaymentOption({
    required this.code,
    required this.label,
    required this.icon,
  });
}

class ProductImage extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final BoxFit fit;

  const ProductImage({
    required this.imageUrl,
    required this.productName,
    this.fit = BoxFit.cover,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim();
    if (cleanUrl.isEmpty || cleanUrl.contains('example.com')) {
      return _placeholder(context);
    }

    return Image.network(
      cleanUrl,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: SportZoneTheme.primary,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: SportZoneTheme.surfaceVariant,
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.image_not_supported_outlined,
              size: 40,
              color: SportZoneTheme.secondary,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 100, // Constrain width so text can wrap if needed, then scale down
              child: Text(
                productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: SportZoneTheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopActionButton extends StatelessWidget {
  final IconData icon;
  final String? badgeText;
  final VoidCallback onTap;

  const TopActionButton({
    required this.icon,
    required this.onTap,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: SportZoneTheme.primary),
          if (badgeText != null)
            Positioned(right: -7, top: -7, child: BadgeBubble(badgeText!)),
        ],
      ),
    );
  }
}

