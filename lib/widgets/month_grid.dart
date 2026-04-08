import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

class MonthGrid extends StatelessWidget {
  final Habit habit;
  final int year;
  final int month;
  final void Function(DateTime) onToggle;

  const MonthGrid({
    super.key,
    required this.habit,
    required this.year,
    required this.month,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday % 7; // 0=Sun
    final today = DateTime.now();
    final isCurrentMonth = today.year == year && today.month == month;

    const dayLabels = ['أح', 'إث', 'ث', 'أر', 'خ', 'ج', 'س'];

    return Column(
      children: [
        // تسميات الأيام
        Row(
          children: dayLabels.map((label) {
            return Expanded(
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: KhatwaTheme.textHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        // الشبكة
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 3,
            crossAxisSpacing: 3,
          ),
          itemCount: firstWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < firstWeekday) {
              return const SizedBox.shrink();
            }
            final day = index - firstWeekday + 1;
            final date = DateTime(year, month, day);
            final isDone = habit.isDoneOn(date);
            final isToday =
                isCurrentMonth && today.day == day;
            final isFuture = date.isAfter(today);

            return GestureDetector(
              onTap: isFuture ? null : () => onToggle(date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: isDone
                      ? KhatwaTheme.primary
                      : isToday
                          ? KhatwaTheme.primaryLight
                          : KhatwaTheme.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isDone
                        ? KhatwaTheme.primaryDark
                        : isToday
                            ? KhatwaTheme.primary
                            : KhatwaTheme.border,
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? const Icon(
                          Icons.check,
                          size: 10,
                          color: Colors.white,
                        )
                      : Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 9,
                            color: isToday
                                ? KhatwaTheme.primary
                                : isFuture
                                    ? KhatwaTheme.textHint
                                    : KhatwaTheme.textSecondary,
                            fontWeight: isToday
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
