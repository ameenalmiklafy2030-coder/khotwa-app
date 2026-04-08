import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/khatwa_icon.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  String _selectedEmoji = '👤';
  String _themeMode = 'system';
  bool _editing = false;

  final _avatarEmojis = [
    '👤','🧑','👨','👩','🧔','👱','🧕','🙋',
    '💪','🦸','🌟','🔥','👣','🎯','🏃','🧘',
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppState>().profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _selectedEmoji = profile?.avatarEmoji ?? '👤';
    _themeMode = profile?.themeMode ?? 'system';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final state = context.read<AppState>();
    final current = state.profile;
    final profile = current != null
        ? current.copyWith(
            name: _nameController.text.trim(),
            avatarEmoji: _selectedEmoji,
            themeMode: _themeMode,
          )
        : UserProfile.newUser(_nameController.text.trim()).copyWith(
            avatarEmoji: _selectedEmoji,
            themeMode: _themeMode,
          );
    await state.saveProfile(profile);
    setState(() => _editing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حفظ الملف الشخصي ✓'),
          backgroundColor: KhatwaTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _confirmReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إعادة ضبط التطبيق'),
          content: const Text(
              'سيتم حذف جميع العادات والبيانات. هل أنت متأكد؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AppState>().resetAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.profile;
    final habits = state.habits;
    final now = DateTime.now();
    final totalDays =
        habits.fold(0, (s, h) => s + h.completedDays.length);
    final thisMonth = habits.fold(
        0, (s, h) => s + h.completedInMonth(now.year, now.month));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── بطاقة الملف الشخصي ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: KhatwaTheme.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  // الأفاتار
                  GestureDetector(
                    onTap: () => setState(() => _editing = true),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _selectedEmoji,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!_editing) ...[
                    Text(
                      profile?.name.isNotEmpty == true
                          ? profile!.name
                          : 'مستخدم خطوة',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'عضو منذ ${_formatDate(profile?.createdAt ?? now)}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () => setState(() => _editing = true),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                      ),
                      child: const Text('تعديل الملف',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ] else ...[
                    // حقل تعديل الاسم
                    TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'اسمك',
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.5))),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // اختيار الأفاتار
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: _avatarEmojis.map((e) {
                        final sel = e == _selectedEmoji;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedEmoji = e),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: sel
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                                child: Text(e,
                                    style:
                                        const TextStyle(fontSize: 20))),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _editing = false),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.white70),
                          child: const Text('إلغاء'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: KhatwaTheme.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('حفظ'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── إحصائيات سريعة ──
            Row(
              children: [
                _StatBadge(
                    value: habits.length.toString(),
                    label: 'عادة نشطة'),
                const SizedBox(width: 10),
                _StatBadge(
                    value: totalDays.toString(), label: 'يوم إجمالاً'),
                const SizedBox(width: 10),
                _StatBadge(
                    value: thisMonth.toString(), label: 'هذا الشهر'),
              ],
            ),

            const SizedBox(height: 14),

            // ── إعدادات المظهر ──
            _SectionCard(
              title: 'المظهر',
              child: Column(
                children: [
                  _ThemeOption(
                    icon: Icons.brightness_auto_rounded,
                    label: 'تلقائي (حسب الجهاز)',
                    selected: _themeMode == 'system',
                    onTap: () => setState(() => _themeMode = 'system'),
                  ),
                  _ThemeOption(
                    icon: Icons.light_mode_rounded,
                    label: 'وضع النهار',
                    selected: _themeMode == 'light',
                    onTap: () => setState(() => _themeMode = 'light'),
                  ),
                  _ThemeOption(
                    icon: Icons.dark_mode_rounded,
                    label: 'الوضع الداكن',
                    selected: _themeMode == 'dark',
                    onTap: () => setState(() => _themeMode = 'dark'),
                    last: true,
                  ),
                  if (_themeMode != (profile?.themeMode ?? 'system'))
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KhatwaTheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('تطبيق المظهر'),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── معلومات التطبيق ──
            _SectionCard(
              title: 'عن التطبيق',
              child: Column(
                children: [
                  _InfoRow(label: 'الإصدار', value: '1.0.0'),
                  _InfoRow(
                      label: 'قاعدة البيانات',
                      value: 'SQLite محلية'),
                  _InfoRow(
                      label: 'إجمالي السجلات',
                      value: '$totalDays يوم',
                      last: true),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── خيارات خطيرة ──
            _SectionCard(
              title: 'البيانات',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child:
                      const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 20),
                ),
                title: const Text('إعادة ضبط التطبيق',
                    style: TextStyle(
                        fontSize: 14, color: Colors.red)),
                subtitle: const Text('حذف كل العادات والبيانات',
                    style: TextStyle(fontSize: 12)),
                trailing: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.red),
                onTap: _confirmReset,
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو',
        'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    return '${months[d.month]} ${d.year}';
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool last;
  final VoidCallback onTap;
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: selected
                  ? KhatwaTheme.primaryLight
                  : KhatwaTheme.surface,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon,
                size: 18,
                color: selected
                    ? KhatwaTheme.primary
                    : KhatwaTheme.textSecondary),
          ),
          title: Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected
                      ? FontWeight.w500
                      : FontWeight.normal,
                  color: selected
                      ? KhatwaTheme.primary
                      : KhatwaTheme.textPrimary)),
          trailing: selected
              ? const Icon(Icons.check_circle_rounded,
                  color: KhatwaTheme.primary, size: 20)
              : const Icon(Icons.radio_button_unchecked_rounded,
                  color: KhatwaTheme.textHint, size: 20),
          onTap: onTap,
        ),
        if (!last)
          const Divider(height: 1, thickness: 0.5,
              indent: 44, color: KhatwaTheme.border),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value, label;
  const _StatBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: KhatwaTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KhatwaTheme.border, width: 0.5),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: KhatwaTheme.primary)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: KhatwaTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KhatwaTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KhatwaTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: KhatwaTheme.textSecondary)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final bool last;
  const _InfoRow(
      {required this.label, required this.value, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: KhatwaTheme.textSecondary)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: KhatwaTheme.textPrimary)),
            ],
          ),
        ),
        if (!last)
          const Divider(height: 1, thickness: 0.5,
              color: KhatwaTheme.border),
      ],
    );
  }
}
