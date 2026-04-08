import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

class StatsScreen extends StatefulWidget {
  final List<Habit> habits;
  const StatsScreen({super.key, required this.habits});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedHabitIndex = 0;

  Habit get _selected => widget.habits[_selectedHabitIndex];

  // إجمالي الأيام المنجزة لكل العادات هذا الشهر
  int get _totalDoneThisMonth {
    final now = DateTime.now();
    return widget.habits.fold(
      0,
      (sum, h) => sum + h.completedInMonth(now.year, now.month),
    );
  }

  // أفضل سلسلة أيام متتالية لعادة معينة
  int _bestStreak(Habit habit) {
    if (habit.completedDays.isEmpty) return 0;
    final sorted = [...habit.completedDays]..sort((a, b) => a.compareTo(b));
    int best = 1, current = 1;
    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > best) best = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return best;
  }

  // السلسلة الحالية
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

  // بيانات آخر 7 أشهر للعادة المختارة
  List<_MonthBar> _monthlyData(Habit habit) {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final month = DateTime(now.year, now.month - 5 + i);
      final done = habit.completedInMonth(month.year, month.month);
      final total = habit.daysInMonth(month.year, month.month);
      return _MonthBar(
        label: _shortMonth(month.month),
        value: done / total,
        done: done,
      );
    });
  }

  String _shortMonth(int m) {
    const names = ['', 'ي', 'ف', 'م', 'أ', 'م', 'يو', 'يل', 'أغ', 'س', 'أ', 'ن', 'د'];
    return names[m];
  }

  String _monthName(int m) {
    const names = ['', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    return names[m];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    if (widget.habits.isEmpty) {
      return const Center(
        child: Text('لا توجد عادات بعد',
            style: TextStyle(color: KhatwaTheme.textSecondary)),
      );
    }

    final bars = _monthlyData(_selected);
    final streak = _currentStreak(_selected);
    final best = _bestStreak(_selected);
    final thisMonthDone = _selected.completedInMonth(now.year, now.month);
    final thisMonthTotal = _selected.daysInMonth(now.year, now.month);
    final pct = thisMonthTotal > 0 ? (thisMonthDone / thisMonthTotal * 100).round() : 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── بطاقات الملخص ──
            Row(
              children: [
                _StatCard(
                  label: 'منجز هذا الشهر',
                  value: _totalDoneThisMonth.toString(),
                  sub: 'عبر كل العادات',
                  color: KhatwaTheme.primary,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  label: 'أفضل عادة',
                  value: widget.habits.isNotEmpty
                      ? widget.habits
                          .reduce((a, b) =>
                              a.completedInMonth(now.year, now.month) >
                                      b.completedInMonth(now.year, now.month)
                                  ? a
                                  : b)
                          .icon
                      : '—',
                  sub: widget.habits.isNotEmpty
                      ? widget.habits
                          .reduce((a, b) =>
                              a.completedInMonth(now.year, now.month) >
                                      b.completedInMonth(now.year, now.month)
                                  ? a
                                  : b)
                          .title
                      : '',
                  color: const Color(0xFF378ADD),
                  isEmoji: true,
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── اختيار العادة ──
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.habits.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final h = widget.habits[i];
                  final selected = i == _selectedHabitIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedHabitIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? KhatwaTheme.primary
                            : KhatwaTheme.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? KhatwaTheme.primary
                              : KhatwaTheme.border,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        '${h.icon} ${h.title}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : KhatwaTheme.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // ── بطاقة العادة المختارة ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: KhatwaTheme.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: KhatwaTheme.border, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: KhatwaTheme.primaryLight,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Center(
                          child: Text(_selected.icon,
                              style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selected.title,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: KhatwaTheme.textPrimary)),
                            Text(
                              '${_monthName(now.month)} ${now.year}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: KhatwaTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: KhatwaTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // شريط التقدم
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: thisMonthTotal > 0
                          ? thisMonthDone / thisMonthTotal
                          : 0,
                      minHeight: 6,
                      backgroundColor: KhatwaTheme.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          KhatwaTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$thisMonthDone من $thisMonthTotal يوماً',
                    style: const TextStyle(
                        fontSize: 11, color: KhatwaTheme.textSecondary),
                  ),

                  const SizedBox(height: 14),

                  // السلسلة وأفضل سجل
                  Row(
                    children: [
                      _MiniStat(
                          icon: '🔥',
                          label: 'السلسلة الحالية',
                          value: '$streak يوم'),
                      const SizedBox(width: 10),
                      _MiniStat(
                          icon: '🏆',
                          label: 'أفضل سلسلة',
                          value: '$best يوم'),
                      const SizedBox(width: 10),
                      _MiniStat(
                          icon: '📅',
                          label: 'إجمالي الأيام',
                          value:
                              '${_selected.completedDays.length} يوم'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── رسم بياني بالأشهر ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: KhatwaTheme.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: KhatwaTheme.border, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الأداء خلال 6 أشهر',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: KhatwaTheme.textPrimary)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: bars.map((bar) {
                        return Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${bar.done}',
                                  style: const TextStyle(
                                      fontSize: 9,
                                      color: KhatwaTheme.textSecondary),
                                ),
                                const SizedBox(height: 3),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut,
                                  height: (bar.value * 80).clamp(4, 80),
                                  decoration: BoxDecoration(
                                    color: bar.value > 0.7
                                        ? KhatwaTheme.primary
                                        : bar.value > 0.4
                                            ? KhatwaTheme.primary
                                                .withOpacity(0.6)
                                            : KhatwaTheme.primaryLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(bar.label,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: KhatwaTheme.textSecondary)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── خريطة الحرارة (أيام الأسبوع) ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: KhatwaTheme.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: KhatwaTheme.border, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('أكثر أيام الأسبوع إنجازاً',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: KhatwaTheme.textPrimary)),
                  const SizedBox(height: 12),
                  _WeekdayHeatmap(habit: _selected),
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

// ── ويدجت خريطة أيام الأسبوع ──
class _WeekdayHeatmap extends StatelessWidget {
  final Habit habit;
  const _WeekdayHeatmap({required this.habit});

  @override
  Widget build(BuildContext context) {
    const labels = ['أح', 'إث', 'ث', 'أر', 'خ', 'ج', 'س'];
    final counts = List.filled(7, 0);
    for (final d in habit.completedDays) {
      counts[d.weekday % 7]++;
    }
    final maxVal = counts.reduce((a, b) => a > b ? a : b);

    return Row(
      children: List.generate(7, (i) {
        final ratio = maxVal > 0 ? counts[i] / maxVal : 0.0;
        return Expanded(
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: ratio > 0
                      ? KhatwaTheme.primary.withOpacity(0.2 + ratio * 0.8)
                      : KhatwaTheme.surface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    counts[i] > 0 ? '${counts[i]}' : '',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: ratio > 0.5 ? Colors.white : KhatwaTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(labels[i],
                  style: const TextStyle(
                      fontSize: 10, color: KhatwaTheme.textSecondary)),
            ],
          ),
        );
      }),
    );
  }
}

class _MonthBar {
  final String label;
  final double value;
  final int done;
  _MonthBar({required this.label, required this.value, required this.done});
}

class _StatCard extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  final bool isEmoji;
  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    this.isEmoji = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: KhatwaTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: KhatwaTheme.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: KhatwaTheme.textSecondary)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: isEmoji ? 28 : 24,
                    fontWeight: FontWeight.w500,
                    color: isEmoji ? null : color)),
            Text(sub,
                style: const TextStyle(
                    fontSize: 11, color: KhatwaTheme.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String icon, label, value;
  const _MiniStat(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: KhatwaTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: KhatwaTheme.border, width: 0.5),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 3),
            Text(value,
                style: const TextStyle(
                    fontSize: 12,
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
