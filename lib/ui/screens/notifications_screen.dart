import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/shop_provider.dart';
import '../theme.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final alertsList = notificationsAsync.value ?? [];

    return Scaffold(
      body: Column(
        children: [
          // App top header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              children: const [
                Icon(
                  Icons.notifications,
                  color: AeroColors.aeroOrange,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Hộp Thư Thông Báo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AeroColors.aeroTextPrimaryDark,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: notificationsAsync.when(
              data: (_) {
                if (alertsList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.notifications_active_outlined,
                          size: 72,
                          color: AeroColors.aeroTextSecondaryDark,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Không có thông báo mới!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AeroColors.aeroTextPrimaryDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Các thông điệp giao nhận hoặc ưu đãi sẽ hiển thị tại đây.',
                          style: TextStyle(
                            color: AeroColors.aeroTextSecondaryDark,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemCount: alertsList.length,
                  itemBuilder: (context, index) {
                    final alert = alertsList[index];
                    final isRead = alert.isRead;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: !isRead
                              ? const BorderSide(
                                  color: Color(0xFFFFB07F), // Soft orange border
                                  width: 1.5,
                                )
                              : BorderSide.none,
                        ),
                        color: isRead
                            ? AeroColors.aeroCardDark
                            : const Color(0xFFFDF6FB), // Soft unread bg tint
                        child: InkWell(
                          onTap: () {
                            ref
                                .read(shopProvider.notifier)
                                .markNotificationAsRead(alert.id);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Unread dot indicator
                                if (!isRead)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4, right: 10),
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AeroColors.aeroOrange,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                else
                                  const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        alert.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isRead
                                              ? AeroColors.aeroTextPrimaryDark
                                              : AeroColors.aeroOrange,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        alert.message,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AeroColors.aeroTextPrimaryDark,
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _formatTimestamp(alert.timestamp),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AeroColors.aeroTextSecondaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AeroColors.aeroOrange),
              ),
              error: (err, stack) => Center(
                child: Text('Lỗi: ${err.toString()}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final durationSec = (DateTime.now().millisecondsSinceEpoch - timestamp) ~/ 1000;
    if (durationSec < 60) {
      return "Mới đây";
    } else if (durationSec < 3600) {
      return "${durationSec ~/ 60} phút trước";
    } else if (durationSec < 86400) {
      return "${durationSec ~/ 3600} giờ trước";
    } else {
      return "${durationSec ~/ 86400} ngày trước";
    }
  }
}
