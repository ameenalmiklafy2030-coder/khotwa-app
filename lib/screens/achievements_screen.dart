import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

// ── نموذج الشارة ──
class Badge {
  final String id;
  final String icon;
  final String title;
  final String desc;
  final bool Function(List<Habit>) isUnlocked;

  const Badge({
    required this.id,
    required this.icon,
    required this.title,
    required this.desc,
    required this.isUnlocked,
  });
}

final allBadges = <Badge>[
  Badge(
    id: 'first_step',
    icon: '👣',
    title: 'الخطوة الأولى',
    desc: 'أنجز يومك الأول',
    isUnlocked: (habits) =>
        habits.any((h) => h.completedDays.isNotEmpty),
  ),
  Badge(
    id: 'week_warrior',
    icon: '🔥',
    title: 'أسبوع النار',
    desc: 'سلسلة 7 أيام متتالية',
    isUnlocked: (habits) => habits.any((h) => _currentStreak(h) >= 7),
  ),
  Badge(
    id: 'half_month',
    icon: '🌙',
    title: 'نصف الشهر',
    desc: 'أنجز 15 يوماً في شهر',
    isUnlocked: (habits) {
      final now = DateTime.now();
      return habits.any(
          (h) => h.completedInMonth(now.year, now.month) >= 15);
    },
  ),
  Badge(
    id: 'full_month',
    icon: '🏆',
    title: 'الشهر الكامل',
    desc: 'أنجز الشهر بالكامل',
    isUnlocked: (habits) {
      final now = DateTime.now();
      return habits.any((h) =>
          h.completedInMonth(now.year, now.month) >=
          h.daysInMonth(now.year, now.month));
    },
  ),
  Badge(
    id: 'multi_habit',
    icon: '🌟',
    title: 'متعدد المواهب',
    desc: 'أضف 3 عادات أو أكثر',
    isUnlocked: (habits) => habits.length >= 3,
  ),
  Badge(
    id: 'consistent',
    icon: '💎',
    title: 'الثبات',
    desc: 'سلسلة 14 يوماً متتالية',
    isUnlocked: (habits) => habits.any((h) => _currentStreak(h) >= 14),
  ),
  Badge(
    id: 'hundred',
    icon: '💯',
    title: 'المئة',
    desc: 'أنجز 100 يوم إجمالاً',
    isUnlocked: (habits) =>
        habits.fold(0, (s, h) => s + h.completedDays.length) >= 100,
  ),
  Badge(
    id: 'prayer_hero',
    icon: '🕌',
    title: 'بطل الصلاة',
    desc: 'أنجز عادة الصلاة 20 يوماً',
    isUnlocked: (habits) {
      final now = DateTime.now();
      return habits
          .where((h) => h.title.contains('صلاة'))
          .any((h) => h.completedInMonth(now.year, now.month) >= 20);
    },
  ),
  Badge(
    id: 'early_bird',
    icon: '🌅',
    title: 'الباكر',
    desc: 'سجّل 30 يوماً إجمالاً',
    isUnlocked: (habits) =>
        habits.fold(0, (s, h) => s + h.completedDays.length) >= 30,
  ),
  Badge(
    id: 'legend',
    icon: '👑',
    title: 'الأسطورة',
    desc: 'سلسلة 30 يوماً متتالية',
    isUnlocked: (habits) => habits.any((h) => _currentStreak(h) >= 30),
  ),
];

int _currentStreak(Habit habit) {
  if (habit.completedDays.isEmpty) return 0;
  final sorted = [...habit.completedDays]..sort((b, a) => a.compareTo(b));
  final today = DateTime.now();
  int streak = 0;
  DateTime check = DateTime(today.year, today.month, today.day);
  for (final d in sorted) {
    final day = DateTime(d.year, d.month, d.day);
    if (day == check) {
      streak++;
      check = check.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }
  return streak;
}

class AchievementsScreen extends StatelessWidget {
  final List<Habit> habits;
  const AchievementsScreen({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final unlocked = allBadges.where((b) => b.isUnlocked(habits)).toList();
    final locked = allBadges.where((b) => !b.isUnlocked(habits)).toList();
    final totalDays = habits.fold(0, (s, h) => s + h.completedDays.length);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── ملخص الإنجازات ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KhatwaTheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('🏅', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${unlocked.length} / ${allBadges.length}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'شارة مفتوحة',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$totalDays',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'يوم إجمالاً',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── شريط التقدم ──
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: allBadges.isNotEmpty
                          ? unlocked.length / allBadges.length
                          : 0,
                      minHeight: 8,
                      backgroundColor: KhatwaTheme.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          KhatwaTheme.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(unlocked.length / allBadges.length * 100).round()}%',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: KhatwaTheme.primary),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── الشارات المفتوحة ──
            if (unlocked.isNotEmpty) ...[
              const Text(
                'شاراتك المكتسبة',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: KhatwaTheme.textPrimary),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: unlocked.length,
                itemBuilder: (_, i) => _BadgeCard(
                    badge: unlocked[i], isUnlocked: true),
              ),
              const SizedBox(height: 20),
            ],

            // ── الشارات المقفلة ──
            if (locked.isNotEmpty) ...[
              const Text(
                'شارات قادمة',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: KhatwaTheme.textSecondary),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: locked.length,
                itemBuilder: (_, i) =>
                    _BadgeCard(badge: locked[i], isUnlocked: false),
              ),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final Badge badge;
  final bool isUnlocked;
  const _BadgeCard({required this.badge, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked ? KhatwaTheme.cardBg : KhatwaTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isUnlocked ? KhatwaTheme.primary.withOpacity(0.3) : KhatwaTheme.border,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة الشارة
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? KhatwaTheme.primaryLight
                  : KhatwaTheme.border.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: ColorFiltered(
                colorFilter: isUnlocked
                    ? const ColorFilter.mode(
                        Colors.transparent, BlendMode.multiply)
                    : const ColorFilter.matrix([
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      1, 0,
                      ]),
                child: Text(
                  badge.icon,
                  style: TextStyle(
                    fontSize: 26,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isUnlocked
                  ? KhatwaTheme.textPrimary
                  : KhatwaTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            badge.desc,
            style: const TextStyle(
                fontSize: 10, color: KhatwaTheme.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (isUnlocked) ...[
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: KhatwaTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '✓ مكتسبة',
                style: TextStyle(
                    fontSize: 9,
                    color: KhatwaTheme.primary,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
