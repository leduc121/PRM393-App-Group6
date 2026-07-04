import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SportZoneState>().currentUser;

    return Scaffold(
      backgroundColor: SportZoneTheme.background,
      appBar: AppBar(
        backgroundColor: SportZoneTheme.background,
        elevation: 0,
        foregroundColor: SportZoneTheme.primary,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton(
            onPressed: user == null
                ? null
                : () => _showEditSheet(context, user),
            child: const Text(
              'Edit',
              style: TextStyle(
                color: SportZoneTheme.error,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Vui lòng đăng nhập lại.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              children: [
                _ProfileHeader(user: user),
                const SizedBox(height: 28),
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _SettingsList(
                  children: [
                    _ProfileAttributeTile(
                      icon: Icons.badge_outlined,
                      label: 'Full name',
                      value: user.name.isEmpty ? 'Chưa cập nhật' : user.name,
                    ),
                    _ProfileAttributeTile(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: user.email.isEmpty ? 'Chưa cập nhật' : user.email,
                    ),
                    _ProfileAttributeTile(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: user.phone.isEmpty ? 'Chưa cập nhật' : user.phone,
                    ),
                    _ProfileAttributeTile(
                      icon: Icons.image_outlined,
                      label: 'Avatar URL',
                      value: user.avatarUrl?.isNotEmpty == true
                          ? user.avatarUrl!
                          : 'Chưa cập nhật',
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  static void _showEditSheet(BuildContext context, User user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(user: user),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: SportZoneTheme.primary,
              backgroundImage: hasAvatar ? NetworkImage(user.avatarUrl!) : null,
              child: hasAvatar
                  ? null
                  : Text(
                      initial,
                      style: const TextStyle(
                        color: SportZoneTheme.onPrimary,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
            Positioned(
              right: -4,
              bottom: 2,
              child: GestureDetector(
                onTap: () => ProfileScreen._showEditSheet(context, user),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: SportZoneTheme.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: SportZoneTheme.borderSubtle),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        'Edit',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          user.name.isEmpty ? 'SportZone User' : user.name,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFD9A52C),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.workspace_premium, size: 15),
              const SizedBox(width: 6),
              Text(
                user.role.toUpperCase() == 'ADMIN' ? 'Admin' : 'Customer',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: SportZoneTheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsList extends StatelessWidget {
  final List<Widget> children;

  const _SettingsList({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SportZoneTheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileAttributeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileAttributeTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SportZoneTheme.borderSubtle)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: SportZoneTheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: SportZoneTheme.primary),
        ),
        title: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: SportZoneTheme.secondary),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: SportZoneTheme.secondary,
        ),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final User user;

  const _EditProfileSheet({required this.user});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _avatarController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _avatarController = TextEditingController(
      text: widget.user.avatarUrl ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Material(
          color: SportZoneTheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: SportZoneTheme.borderSubtle,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Edit profile',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                _field('Full name', _nameController, Icons.badge_outlined),
                const SizedBox(height: 12),
                _field('Phone', _phoneController, Icons.phone_outlined),
                const SizedBox(height: 12),
                _field('Avatar URL', _avatarController, Icons.image_outlined),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SportZoneTheme.primary,
                      foregroundColor: SportZoneTheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: SportZoneTheme.onPrimary,
                            ),
                          )
                        : const Text(
                            'SAVE CHANGES',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final error = await context.read<SportZoneState>().updateProfileAsync(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      avatarUrl: _avatarController.text.trim().isEmpty
          ? null
          : _avatarController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.pop(context);
  }
}
