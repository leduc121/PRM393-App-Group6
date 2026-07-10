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
                  'Profile',
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
        if (user.role.toUpperCase() == 'ADMIN') ...[
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
                  'Admin',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: SportZoneTheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        _MembershipCard(user: user),
        const SizedBox(height: 24),
        const _VouchersSection(),
      ],
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final User user;
  const _MembershipCard({required this.user});

  Color _getTierColor() {
    switch (user.membershipTier) {
      case 'silver': return const Color(0xFFC0C0C0);
      case 'gold': return const Color(0xFFFFD700);
      case 'platinum': return const Color(0xFFE5E4E2);
      default: return const Color(0xFFCD7F32); // Bronze
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextTier = user.nextTierName;
    final progress = user.tierProgress;
    final color = _getTierColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thành viên',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SportZoneTheme.secondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.tierDisplay,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Đã chi tiêu: ${formatVnd(user.totalSpent)}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          if (nextTier != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white54,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Còn ${formatVnd(user.nextTierThreshold! - user.totalSpent)} nữa để đạt $nextTier (${(progress * 100).toStringAsFixed(1)}%)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: SportZoneTheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            const Text(
              'Bạn đã đạt bậc cao nhất! 💎',
              style: TextStyle(fontWeight: FontWeight.w700, color: SportZoneTheme.secondary),
            ),
          ]
        ],
      ),
    );
  }
}

class _VouchersSection extends StatefulWidget {
  const _VouchersSection();
  @override
  State<_VouchersSection> createState() => _VouchersSectionState();
}

class _VouchersSectionState extends State<_VouchersSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SportZoneState>().fetchMyVouchers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SportZoneState>();
    final vouchers = state.availableVouchers;

    if (vouchers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Voucher của tôi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: SportZoneTheme.electricLime,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${vouchers.length}',
                style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: vouchers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final voucher = vouchers[index];
              final isUsed = voucher.isUsed;
              return Container(
                width: 240,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUsed ? SportZoneTheme.surfaceVariant : SportZoneTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUsed ? SportZoneTheme.borderSubtle : SportZoneTheme.primary.withOpacity(0.1),
                  ),
                  boxShadow: isUsed ? null : const [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          voucher.code,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: isUsed ? SportZoneTheme.secondary : SportZoneTheme.primary,
                            decoration: isUsed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (isUsed)
                          const Text('ĐÃ DÙNG', style: TextStyle(fontSize: 10, color: SportZoneTheme.error, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      voucher.discountDisplay,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isUsed ? SportZoneTheme.secondary : const Color(0xFF00C853),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Đơn tối thiểu: ${formatVnd(voucher.minOrderValue)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: SportZoneTheme.secondary),
                    ),
                  ],
                ),
              );
            },
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
