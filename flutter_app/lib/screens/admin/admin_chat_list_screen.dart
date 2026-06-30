import 'package:flutter/material.dart';
import 'package:flutter_app/core.dart';
import 'package:flutter_app/screens/admin/admin_chat_detail_screen.dart';
import 'dart:async';

class AdminChatListScreen extends StatefulWidget {
  const AdminChatListScreen({super.key});

  @override
  State<AdminChatListScreen> createState() => _AdminChatListScreenState();
}

class _AdminChatListScreenState extends State<AdminChatListScreen> {
  bool _isLoading = true;
  String _error = '';
  List<Map<String, dynamic>> _sessions = [];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) _fetchSessions(quiet: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchSessions({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _isLoading = true;
        _error = '';
      });
    }

    final result = await ApiService.getChatSessions();
    if (!mounted) return;

    if (result.isSuccess) {
      final raw = result.data;
      if (raw is List) {
        setState(() {
          _sessions = List<Map<String, dynamic>>.from(raw);
          _isLoading = false;
        });
      }
    } else {
      if (!quiet) {
        setState(() {
          _error = result.errorMessage ?? 'Lỗi tải danh sách';
          _isLoading = false;
        });
      }
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
        title: const Text(
          'Quản lý Tin nhắn',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: () => _fetchSessions(),
                  child: _sessions.isEmpty
                      ? ListView(
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(
                                child: Text('Chưa có tin nhắn nào từ khách hàng.'),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          itemCount: _sessions.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final session = _sessions[index];
                            final uid = session['user_uid'];
                            final name = session['user_fullName'] ?? 'Khách hàng';
                            final email = session['user_email'] ?? '';
                            final avatar = session['user_avatarUrl'];
                            final unreadCount = int.tryParse(session['unread_count']?.toString() ?? '0') ?? 0;
                            final lastActive = session['last_activity'] != null
                                ? DateTime.tryParse(session['last_activity'].toString())?.toLocal()
                                : null;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              tileColor: SportZoneTheme.surface,
                              leading: CircleAvatar(
                                backgroundColor: SportZoneTheme.electricLime,
                                backgroundImage: avatar != null && avatar.isNotEmpty
                                    ? NetworkImage(avatar)
                                    : null,
                                child: avatar == null || avatar.isEmpty
                                    ? Text(
                                        name[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: SportZoneTheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                email,
                                style: const TextStyle(color: SportZoneTheme.secondary),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (lastActive != null)
                                    Text(
                                      '${lastActive.hour.toString().padLeft(2, '0')}:${lastActive.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 12, color: SportZoneTheme.secondary),
                                    ),
                                  const SizedBox(height: 4),
                                  if (unreadCount > 0)
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        unreadCount.toString(),
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AdminChatDetailScreen(
                                      uid: uid,
                                      customerName: name,
                                    ),
                                  ),
                                ).then((_) => _fetchSessions(quiet: true));
                              },
                            );
                          },
                        ),
                ),
    );
  }
}
