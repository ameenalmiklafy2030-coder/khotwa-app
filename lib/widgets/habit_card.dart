import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import 'month_grid.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final int year;
  final int month;
  final void Function(DateTime) onToggle;
  final VoidCallback? onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.year,
    required this.month,
    required this.onToggle,
    this.onDelete,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnim;
  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );
    _expandAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _expanded = !_expanded);
    _expanded ? _controller.forward() : _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.habit.completedInMonth(widget.year, widget.month);
    final total = widget.habit.daysInMonth(widget.year, widget.month);
    final progress = widget.habit.progressInMonth(widget.year, widget.month);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: KhatwaTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KhatwaTheme.border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة
            GestureDetector(
              onTap: _toggleExpand,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  // أيقونة العادة
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: KhatwaTheme.primaryLight,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Center(
                      child: Text(
                        widget.habit.icon,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // العنوان والتقدم
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: KhatwaTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$done / $total يوم',
                          style: const TextStyle(
                            fontSize: 11,
                            color: KhatwaTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // نسبة مئوية
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: KhatwaTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  // زر الطي
                  AnimatedRotation(
                    turns: _expanded ? 0 : -0.25,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: KhatwaTheme.textHint,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // شريط التقدم
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: KhatwaTheme.border,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  KhatwaTheme.primary,
                ),
              ),
            ),

            // الشبكة (قابلة للطي)
            SizeTransition(
              sizeFactor: _expandAnim,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  MonthGrid(
                    habit: widget.habit,
                    year: widget.year,
                    month: widget.month,
                    onToggle: widget.onToggle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
