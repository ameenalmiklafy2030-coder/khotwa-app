import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class RemindersScreen extends StatefulWidget {
  final List<Habit> habits;
  const RemindersScreen({super.key, required this.habits});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<HabitReminder> _reminders = [];
  bool _loading = true;
  bool _globalEnabled = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await HabitReminder.loadAll();
    // إذا لم يكن للعادة تذكير، أنشئ واحداً افتراضياً
    final reminders = widget.habits.map((h) {
      return loaded.firstWhere(
        (r) => r.habitId == h.id,
        orElse: () => HabitReminder(
          habitId: h.id,
          enabled: false,
          hour: 8,
          minute: 0,
        ),
      );
    }).toList();

    setState(() {
      _reminders = reminders;
      _loading = false;
    });
  }

  Future<void> _save() async {
    await HabitReminder.saveAll(_reminders);
    // إعادة جدولة كل التذكيرات
    await NotificationService().cancelAll();
    for (int i = 0; i < _reminders.length; i++) {
      final r = _reminders[i];
      final habit = widget.habits.firstWhere((h) => h.id == r.habitId);
      if (r.enabled && _globalEnabled) {
        await NotificationService().scheduleHabitReminder(
          id: i,
          habitTitle: habit.title,
          habitIcon: habit.icon,
          time: r.timeOfDay,
        );
      }
    }
  }

  Future<void> _pickTime(int index) async {
    final r = _reminders[index];
    final picked = await showTimePicker(
      context: context,
      initialTime: r.timeOfDay,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: KhatwaTheme.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _reminders[index] = r.copyWith(
          hour: picked.hour,
          minute: picked.minute,
          enabled: true,
        );
      });
      await _save();
    }
  }

  Future<void> _toggleReminder(int index, bool value) async {
    setState(() {
      _reminders[index] = _reminders[index].copyWith(enabled: value);
    });
    await _save();
  }

  Future<void> _sendTest(int index) async {
    final habit = widget.habits.firstWhere(
        (h) => h.id == _reminders[index].habitId);
    await NotificationService()
        .showTestNotification(habit.title, habit.icon);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم إرسال إشعار تجريبي! 🔔'),
          backgroundColor: KhatwaTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: KhatwaTheme.primary));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── بطاقة التحكم الرئيسي ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _globalEnabled
                    ? KhatwaTheme.primary
                    : KhatwaTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _globalEnabled
                        ? KhatwaTheme.primary
                        : KhatwaTheme.border,
                    width: 0.5),
              ),
              child: Row(
                children: [
                  const Text('🔔', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التذكيرات اليومية',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _globalEnabled
                                ? Colors.white
                                : KhatwaTheme.textPrimary,
                          ),
                        ),
                        Text(
                          _globalEnabled
                              ? 'التنبيهات مفعّلة'
                              : 'التنبيهات متوقفة',
                          style: TextStyle(
                            fontSize: 12,
                            color: _globalEnabled
                                ? Colors.white70
                                : KhatwaTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _globalEnabled,
                    onChanged: (v) async {
                      setState(() => _globalEnabled = v);
                      await _save();
                    },
                    activeColor: Colors.white,
                    activeTrackColor: Colors.white.withOpacity(0.4),
                    inactiveThumbColor: KhatwaTheme.textSecondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── إحصائية سريعة ──
            Row(
              children: [
                _QuickStat(
                  label: 'تذكيرات نشطة',
                  value: _reminders.where((r) => r.enabled).length.toString(),
                  icon: '✅',
                ),
                const SizedBox(width: 10),
                _QuickStat(
                  label: 'إجمالي العادات',
                  value: widget.habits.length.toString(),
                  icon: '📋',
                ),
                const SizedBox(width: 10),
                _QuickStat(
                  label: 'أبكر تذكير',
                  value: _reminders.where((r) => r.enabled).isEmpty
                      ? '--'
                      : _reminders
                          .where((r) => r.enabled)
                          .reduce((a, b) =>
                              a.hour * 60 + a.minute < b.hour * 60 + b.minute
                                  ? a
                                  : b)
                          .timeString,
                  icon: '🌅',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── تذكيرات العادات ──
            const Text(
              'تذكيرات العادات',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: KhatwaTheme.textPrimary),
            ),
            const SizedBox(height: 10),

            ...List.generate(widget.habits.length, (i) {
              final habit = widget.habits[i];
              final reminder = _reminders[i];
              return _ReminderCard(
                habit: habit,
                reminder: reminder,
                globalEnabled: _globalEnabled,
                onToggle: (v) => _toggleReminder(i, v),
                onPickTime: () => _pickTime(i),
                onTest: () => _sendTest(i),
              );
            }),

            const SizedBox(height: 16),

            // ── نصائح ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: KhatwaTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('💡 نصائح للتذكيرات',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: KhatwaTheme.primaryDark)),
                  SizedBox(height: 8),
                  _Tip(text: 'اختر وقتاً ثابتاً يومياً لكل عادة'),
                  _Tip(text: 'الصلاة: اجعل التذكير قبل الأذان بـ 10 دقائق'),
                  _Tip(text: 'المشي: الصباح الباكر أفضل وقت'),
                  _Tip(text: 'القراءة: بعد العشاء وقت هادئ مناسب'),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ── بطاقة تذكير عادة واحدة ──
class _ReminderCard extends StatelessWidget {
  final Habit habit;
  final HabitReminder reminder;
  final bool globalEnabled;
  final void Function(bool) onToggle;
  final VoidCallback onPickTime;
  final VoidCallback onTest;

  const _ReminderCard({
    required this.habit,
    required this.reminder,
    required this.globalEnabled,
    required this.onToggle,
    required this.onPickTime,
    required this.onTest,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = reminder.enabled && globalEnabled;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: KhatwaTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? KhatwaTheme.primary.withOpacity(0.3)
              : KhatwaTheme.border,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                // أيقونة العادة
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isActive
                        ? KhatwaTheme.primaryLight
                        : KhatwaTheme.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(habit.icon,
                        style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 10),

                // اسم العادة والوقت
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: KhatwaTheme.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: onPickTime,
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: isActive
                                  ? KhatwaTheme.primary
                                  : KhatwaTheme.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              reminder.enabled
                                  ? reminder.timeString
                                  : 'اضغط لتحديد الوقت',
                              style: TextStyle(
                                fontSize: 12,
                                color: isActive
                                    ? KhatwaTheme.primary
                                    : KhatwaTheme.textHint,
                                fontWeight: isActive
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // مفتاح التفعيل
                Switch(
                  value: reminder.enabled,
                  onChanged: globalEnabled ? onToggle : null,
                  activeColor: KhatwaTheme.primary,
                ),
              ],
            ),

            // زر اختيار الوقت + اختبار
            if (reminder.enabled) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPickTime,
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('تغيير الوقت',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: KhatwaTheme.primary,
                        side: const BorderSide(
                            color: KhatwaTheme.primary, width: 0.5),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTest,
                      icon: const Icon(Icons.notifications_outlined, size: 14),
                      label: const Text('اختبار',
                          style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: KhatwaTheme.textSecondary,
                        side: const BorderSide(
                            color: KhatwaTheme.border, width: 0.5),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label, value, icon;
  const _QuickStat(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: KhatwaTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KhatwaTheme.border, width: 0.5),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: KhatwaTheme.textPrimary)),
            Text(label,
                style: const TextStyle(
                    fontSize: 9, color: KhatwaTheme.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final String text;
  const _Tip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style:
                  TextStyle(fontSize: 12, color: KhatwaTheme.primaryDark)),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12, color: KhatwaTheme.primaryDark)),
          ),
        ],
      ),
    );
  }
}
