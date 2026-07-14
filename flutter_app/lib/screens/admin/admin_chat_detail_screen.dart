import 'package:flutter/material.dart';
import 'package:flutter_app/core.dart';
import 'dart:async';

class AdminChatDetailScreen extends StatefulWidget {
  final String uid;
  final String customerName;

  const AdminChatDetailScreen({
    super.key,
    required this.uid,
    required this.customerName,
  });

  @override
  State<AdminChatDetailScreen> createState() => _AdminChatDetailScreenState();
}

class _AdminChatDetailScreenState extends State<AdminChatDetailScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  Timer? _pollingTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) _fetchMessages(quiet: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages({bool quiet = false}) async {
    final result = await ApiService.getMessagesForAdmin(widget.uid);
    if (!mounted) return;

    if (result.isSuccess) {
      final raw = result.data;
      if (raw is List) {
        final newMessages = raw
            .whereType<Map<String, dynamic>>()
            .map((json) => ChatMessage.fromJson(json, isCurrentUserAdmin: true))
            .toList();
        
        final shouldScroll = _messages.length != newMessages.length;
        
        setState(() {
          _messages = newMessages;
          _isLoading = false;
        });

        if (shouldScroll && scrollController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }
      }
    }
  }

  Future<void> _send() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    controller.clear();
    
    // Add locally for instant UI
    setState(() {
      _messages.add(
        ChatMessage(message: text, isUser: true, isRead: false),
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });

    final result = await ApiService.replyMessage(widget.uid, text);
    if (result.isSuccess) {
      _fetchMessages(quiet: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      appBar: AppBar(
        backgroundColor: SportZoneTheme.surface,
        foregroundColor: SportZoneTheme.primary,
        elevation: 0,
        title: Text(
          widget.customerName,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(color: SportZoneTheme.borderSubtle, height: 1),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _chatBubble(_messages[index]);
                      },
                    ),
            ),
            Container(
              color: SportZoneTheme.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn trả lời...',
                        filled: true,
                        fillColor: SportZoneTheme.surfaceVariant,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
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
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: SportZoneTheme.electricLime,
                    child: Text(
                      widget.customerName.isNotEmpty ? widget.customerName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: SportZoneTheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.customerName.toUpperCase(),
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
}
