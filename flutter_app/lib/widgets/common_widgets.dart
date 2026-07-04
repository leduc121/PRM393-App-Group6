import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
    final notifications = state.notifications;
    final unreadCount = notifications.where((item) => !item.isRead).length;
    final isEmpty = notifications.isEmpty;

    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _NotificationsHeader(
              unreadCount: unreadCount,
              showUnreadBadge: !isEmpty,
              showCustomizeHint: isEmpty,
            ),
            if (isEmpty)
              const Expanded(child: _EmptyNotificationsView())
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SportZoneTheme.surface,
                    foregroundColor: SportZoneTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: const BorderSide(
                      color: SportZoneTheme.primary,
                      width: 1.5,
                    ),
                  ),
                  onPressed: unreadCount == 0
                      ? null
                      : state.markAllNotificationsRead,
                  child: Text(
                    'ĐÁNH DẤU TẤT CẢ LÀ ĐÃ ĐỌC',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    return _NotificationTile(item: notifications[index]);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  final int unreadCount;
  final bool showUnreadBadge;
  final bool showCustomizeHint;

  const _NotificationsHeader({
    required this.unreadCount,
    required this.showUnreadBadge,
    required this.showCustomizeHint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: SportZoneTheme.primary,
                ),
                onPressed: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
              ),
              Expanded(
                child: Text(
                  'Notifications',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (showUnreadBadge)
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
                )
              else
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {},
                ),
            ],
          ),
          if (showCustomizeHint)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: SportZoneTheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Customize your notifications!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SportZoneTheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyNotificationsView extends StatelessWidget {
  const _EmptyNotificationsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/notification_empty.png',
              width: 132,
              height: 132,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              'No notifications yet',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: SportZoneTheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Your notifications will appear here once you've received them.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SportZoneTheme.secondary,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Missing notifications?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SportZoneTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Go to historical notifications.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF2C7C99),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              _categoryIcon(item.category),
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
                    if (!item.isRead) const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: item.isRead
                              ? SportZoneTheme.secondary
                              : SportZoneTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SportZoneTheme.secondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.timeAgo,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color.fromRGBO(93, 95, 95, 0.7),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (!item.isRead)
            Container(width: 4, height: 44, color: SportZoneTheme.electricLime),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'PAYMENT' => Icons.payments_outlined,
      'ORDER' => Icons.receipt_long,
      'DELIVERY' => Icons.local_shipping,
      'PROMO' => Icons.confirmation_number,
      _ => Icons.notifications_outlined,
    };
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
    var cleanUrl = imageUrl.trim();
    if (cleanUrl.isEmpty || cleanUrl.contains('example.com')) {
      if (cleanUrl.contains('nike-tshirt')) {
        cleanUrl =
            'https://images.unsplash.com/photo-1581655353564-df123a1eb820?auto=format&fit=crop&w=600&q=80';
      } else if (cleanUrl.contains('adidas-short')) {
        cleanUrl =
            'https://images.unsplash.com/photo-1508962914676-134849a727f0?auto=format&fit=crop&w=600&q=80';
      } else if (cleanUrl.contains('puma-tshirt')) {
        cleanUrl =
            'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=600&q=80';
      } else if (cleanUrl.contains('ua-pants')) {
        cleanUrl =
            'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?auto=format&fit=crop&w=600&q=80';
      } else if (cleanUrl.contains('nike-jacket')) {
        cleanUrl =
            'https://images.unsplash.com/photo-1548883354-7622d03aca27?auto=format&fit=crop&w=600&q=80';
      } else {
        return _placeholder(context);
      }
    }

    if (kIsWeb && cleanUrl.startsWith('http')) {
      cleanUrl =
          '${ApiService.baseUrl}/products/image-proxy?url=${Uri.encodeComponent(cleanUrl)}';
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
              width:
                  100, // Constrain width so text can wrap if needed, then scale down
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
    super.key,
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
