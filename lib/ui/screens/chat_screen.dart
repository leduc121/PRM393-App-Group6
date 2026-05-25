import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/shop_provider.dart';
import '../theme.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    ref.read(shopProvider.notifier).updateChatInput(text);
    
    // Read compile-time environment variable GEMINI_API_KEY
    const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    ref.read(shopProvider.notifier).sendChatMessage(apiKey);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopProvider);
    final chatHistoryAsync = ref.watch(chatMessagesStreamProvider);
    final chatHistory = chatHistoryAsync.value ?? [];

    // Scroll to bottom when state updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Scaffold(
      body: Column(
        children: [
          // Chat screen bar top header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AeroColors.aeroOrange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.electric_bolt,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aero - Trợ lý Thể thao ⚡',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AeroColors.aeroTextPrimaryDark,
                          ),
                        ),
                        Text(
                          state.isChatLoading
                              ? "Aero đang gõ phản hồi..."
                              : "Trực tuyến • Sẵn sàng tư vấn",
                          style: TextStyle(
                            fontSize: 11,
                            color: state.isChatLoading
                                ? AeroColors.aeroOrange
                                : AeroColors.aeroEmerald,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Eraser chat button
                IconButton(
                  onPressed: () {
                    ref.read(shopProvider.notifier).clearChatHistory();
                  },
                  icon: const Icon(
                    Icons.delete_sweep,
                    color: AeroColors.aeroTextSecondaryDark,
                    size: 18,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AeroColors.aeroM3Container,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AeroColors.aeroM3Outline),
          // Chat message list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20.0),
              itemCount: chatHistory.length + (state.isChatLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatHistory.length) {
                  return _buildLoadingBubble();
                }

                final msg = chatHistory[index];
                final isUser = msg.sender == 'user';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment:
                        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        padding: const EdgeInsets.all(14.0),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AeroColors.aeroOrange
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 16),
                          ),
                        ),
                        child: Text(
                          msg.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Suggestion chips
          _buildSuggestionChips(),
          const SizedBox(height: 4),
          // Entry footer keyboard
          Container(
            padding: const EdgeInsets.all(12.0),
            color: const Color(0xFF1E293B), // Dark input bar
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: (_) => _sendMessage(),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nhắn tin với Trợ lý Aero...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: AeroColors.aeroOrange,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AeroColors.aeroOrange,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Aero đang phân tích dinh dưỡng...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = [
      "Tư vấn mua Whey Isolate 💪",
      "Mã giảm giá ở đâu? 🎟️",
      "Địa chỉ shop ở đâu? 📍"
    ];

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              backgroundColor: const Color(0xFF1E293B),
              side: const BorderSide(color: Color(0xFF334155)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              label: Text(
                suggestion,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                ref.read(shopProvider.notifier).updateChatInput(suggestion);
                _sendMessage();
              },
            ),
          );
        },
      ),
    );
  }
}
