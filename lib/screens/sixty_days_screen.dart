import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class SixtyDaysScreen extends StatelessWidget {
  const SixtyDaysScreen({super.key});

  // احسب أقوى سلسلة متتالية
  int _bestStreak(Habit habit) {
    if (habit.completedDays.isEmpty) return 0;
    final sorted = [...habit.completedDays]..sort((a, b) => a.compareTo(b));
    int best = 1, cur = 1;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
        cur++;
        if (cur > best) best = cur;
      } else if (sorted[i].difference(sorted[i - 1]).inDays > 1) {
        cur = 1;
      }
    }
    return best;
  }

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

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<AppState>().habits;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // البطاقة العلمية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF7F77DD),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('🧠', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  const Text('نمط الـ 66 يوم',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                  const SizedBox(height: 6),
                  Text(
                    'البحث العلمي يثبت أن تكوين العادة الحقيقية يحتاج 66 يوماً في المتوسط — وليس 21 يوماً كما يُشاع',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'مصدر: Phillippa Lally — University College London 2010',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // المراحل العلمية
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.borderColor, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('مراحل تكوين العادة',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: KhatwaTheme.textPrimary)),
                  const SizedBox(height: 12),
                  _Phase(
                      days: '١ — ٢١',
                      title: 'مرحلة البدء',
                      desc: 'الأصعب — الإرادة تحارب الجاذبية القديمة',
                      color: const Color(0xFFF09595),
                      progress: 0.32),
                  _Phase(
                      days: '٢٢ — ٤٤',
                      title: 'مرحلة الترسيخ',
                      desc: 'يبدأ الدماغ ببناء مسارات عصبية جديدة',
                      color: const Color(0xFFEF9F27),
                      progress: 0.65),
                  _Phase(
                      days: '٤٥ — ٦٦',
                      title: 'مرحلة الأتمتة',
                      desc: 'العادة تصبح تلقائية — أقل مجهود أكثر ثبات',
                      color: KhatwaTheme.primary,
                      progress: 1.0,
                      last: true),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // تقدم العادات على مقياس 66 يوم
            const Text('عاداتك على مقياس 66 يوم',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: KhatwaTheme.textPrimary)),
            const SizedBox(height: 8),

            if (habits.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: context.borderColor, width: 0.5),
                ),
                child: const Center(
                  child: Text('أضف عادات لترى تقدمك',
                      style: TextStyle(
                          fontSize: 14, color: KhatwaTheme.textSecondary)),
                ),
              )
            else
              ...habits.map((h) {
                final streak = _currentStreak(h);
                final best = _bestStreak(h);
                final pct66 = (streak / 66).clamp(0.0, 1.0);
                final phase = streak < 22
                    ? 'البدء'
                    : streak < 45
                        ? 'الترسيخ'
                        : 'الأتمتة';
                final phaseColor = streak < 22
                    ? const Color(0xFFF09595)
                    : streak < 45
                        ? const Color(0xFFEF9F27)
                        : KhatwaTheme.primary;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: context.borderColor, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(h.icon,
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(h.title,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: KhatwaTheme.textPrimary)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: phaseColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(phase,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: phaseColor,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // مقياس 66 يوم مع نقاط المراحل
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct66,
                              minHeight: 10,
                              backgroundColor: KhatwaTheme.border,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  phaseColor),
                            ),
                          ),
                          // علامات المراحل
                          Positioned(
                            left: null,
                            right: null,
                            top: 0,
                            bottom: 0,
                            child: Row(
                              children: [
                                // يوم 21
                                SizedBox(
                                    width: MediaQuery.of(context)
                                            .size
                                            .width *
                                        0.28),
                                Container(
                                  width: 2,
                                  height: 10,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                // يوم 44
                                SizedBox(
                                    width: MediaQuery.of(context)
                                            .size
                                            .width *
                                        0.27),
                                Container(
                                  width: 2,
                                  height: 10,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('السلسلة الحالية: $streak يوم',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: KhatwaTheme.textSecondary)),
                          Text('أفضل سلسلة: $best يوم',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: KhatwaTheme.textSecondary)),
                          Text('${(pct66 * 100).round()}%',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: phaseColor,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _Phase extends StatelessWidget {
  final String days, title, desc;
  final Color color;
  final double progress;
  final bool last;

  const _Phase({
    required this.days,
    required this.title,
    required this.desc,
    required this.color,
    required this.progress,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 44,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(days,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: color)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: KhatwaTheme.textPrimary)),
                    Text(desc,
                        style: const TextStyle(
                            fontSize: 11,
                            color: KhatwaTheme.textSecondary)),
                  ],
                ),
              ),
              Container(
                width: 50,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: KhatwaTheme.border,
                ),
                child: FractionallySizedBox(
                  widthFactor: progress,
                  heightFactor: 1,
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!last)
          const Divider(height: 1, thickness: 0.5, color: KhatwaTheme.border),
      ],
    );
  }
}
