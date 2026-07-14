import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';
import 'dart:async';


class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SportZoneState>().fetchMessages();
    });
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        context.read<SportZoneState>().fetchMessages();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SPORTZONE SUPPORT',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    onPressed: state.clearChat,
                    icon: const Icon(
                      Icons.delete_sweep,
                      color: SportZoneTheme.error,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: SportZoneTheme.borderSubtle),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                itemCount: state.chatMessages.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: SportZoneTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'HÔM NAY',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: SportZoneTheme.secondary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    );
                  }
                  final msgIndex = index - 1;
                  final msg = state.chatMessages[msgIndex];
                  return _chatBubble(msg);
                },
              ),
            ),
            Container(
              color: SportZoneTheme.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: SportZoneTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: SportZoneTheme.primary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn tư vấn...',
                        filled: true,
                        fillColor: SportZoneTheme.surfaceVariant,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      onSubmitted: (_) => _send(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _send(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: SportZoneTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: SportZoneTheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatBubble(ChatMessage msg) {
    final alignEnd = msg.isUser;
    
    String timeStr = '';
    if (msg.sentAt != null) {
      final d = msg.sentAt!.day.toString().padLeft(2, '0');
      final mo = msg.sentAt!.month.toString().padLeft(2, '0');
      final h = msg.sentAt!.hour.toString().padLeft(2, '0');
      final m = msg.sentAt!.minute.toString().padLeft(2, '0');
      timeStr = '$d/$mo $h:$m';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!alignEnd)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: SportZoneTheme.electricLime,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      size: 12,
                      color: SportZoneTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'SPORTZONE ADMIN',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ),
          Row(
            mainAxisAlignment:
                alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: alignEnd ? Colors.black : SportZoneTheme.borderSubtle,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(alignEnd ? 16 : 4),
                      bottomRight: Radius.circular(alignEnd ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    msg.message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: alignEnd ? Colors.white : SportZoneTheme.primary,
                        ),
                  ),
                ),
              ),
            ],
          ),
          if (timeStr.isNotEmpty || alignEnd)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4, left: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (timeStr.isNotEmpty)
                    Text(
                      timeStr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SportZoneTheme.secondary,
                            fontSize: 10,
                          ),
                    ),
                  if (alignEnd) ...[
                    if (timeStr.isNotEmpty) const SizedBox(width: 4),
                    Icon(
                      msg.isRead ? Icons.done_all : Icons.check,
                      size: 14,
                      color: msg.isRead ? Colors.blue : SportZoneTheme.secondary,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _send(BuildContext context) {
    final state = context.read<SportZoneState>();
    final text = controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    controller.clear();
    state.sendChatMessage(text);
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

