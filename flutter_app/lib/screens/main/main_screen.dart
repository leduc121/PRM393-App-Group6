import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';
import 'package:flutter_app/screens/admin/admin_chat_list_screen.dart';

class _AccountMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _AccountMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? SportZoneTheme.primary;
    return ListTile(
      leading: Icon(icon, color: itemColor),
      title: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: itemColor,
          fontWeight: FontWeight.w900,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _FooterNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FooterNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: double.infinity,
          decoration: BoxDecoration(
            color: selected
                ? SportZoneTheme.surfaceContainerLow
                : Colors.transparent,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: selected
                    ? SportZoneTheme.primary
                    : SportZoneTheme.secondary,
                size: 25,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected
                      ? SportZoneTheme.primary
                      : SportZoneTheme.secondary,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportZoneFooter extends StatelessWidget {
  final int selectedIndex;
  final User? user;
  final ValueChanged<int> onTabSelected;

  const _SportZoneFooter({
    required this.selectedIndex,
    required this.user,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: SportZoneTheme.background,
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 74,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: SportZoneTheme.surface,
                  borderRadius: BorderRadius.circular(38),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _FooterNavItem(
                      icon: Icons.grid_on,
                      label: 'Shop',
                      selected: selectedIndex == 0,
                      onTap: () => onTabSelected(0),
                    ),
                    _FooterNavItem(
                      icon: Icons.location_on,
                      label: 'Map',
                      selected: selectedIndex == 1,
                      onTap: () => onTabSelected(1),
                    ),
                    _FooterNavItem(
                      icon: Icons.chat_bubble_outline,
                      label: 'Chat',
                      selected: selectedIndex == 2,
                      onTap: () => onTabSelected(2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _showAccountMenu(context),
              child: CircleAvatar(
                radius: 34,
                backgroundColor: SportZoneTheme.electricLime,
                backgroundImage:
                    user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                    ? NetworkImage(user!.avatarUrl!)
                    : null,
                child: user?.avatarUrl == null || user!.avatarUrl!.isEmpty
                    ? Text(
                        (user?.name.isNotEmpty == true)
                            ? user!.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: SportZoneTheme.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountMenu(BuildContext context) {
    final state = context.read<SportZoneState>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Material(
              color: SportZoneTheme.surface,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AccountMenuItem(
                      icon: Icons.person_outline,
                      label: 'Profile',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    _AccountMenuItem(
                      icon: Icons.timeline_outlined,
                      label: 'Trạng thái',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.pushNamed(context, '/order-status');
                      },
                    ),
                    if (state.currentUser?.role == 'admin')
                      _AccountMenuItem(
                        icon: Icons.confirmation_num_outlined,
                        label: 'Quản lý Vouchers',
                        onTap: () {
                          Navigator.pop(sheetContext);
                          Navigator.pushNamed(context, '/admin/vouchers');
                        },
                      ),
                    const Divider(height: 1),
                    _AccountMenuItem(
                      icon: Icons.logout,
                      label: 'Logout',
                      color: SportZoneTheme.error,
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        await state.logoutAsync();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, '/login');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    final user = state.currentUser;
    final isAdmin = user?.role == 'admin';
    return Scaffold(
      body: user == null
          ? const Center(child: Text('Vui lòng đăng nhập lại.'))
          : IndexedStack(
              index: state.selectedTabIndex,
              children: [
                const HomeScreen(),
                const StoreLocationScreen(),
                isAdmin ? const AdminChatListScreen() : const ChatScreen(),
              ],
            ),
      bottomNavigationBar: _SportZoneFooter(
        selectedIndex: state.selectedTabIndex,
        user: user,
        onTabSelected: state.setSelectedTabIndex,
      ),
    );
  }
}
