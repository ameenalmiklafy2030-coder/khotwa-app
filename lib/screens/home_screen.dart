import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../widgets/habit_card.dart';
import 'add_habit_sheet.dart';

class HomeBody extends StatefulWidget {
  final List<Habit> habits;
  final void Function(Habit, DateTime) onToggle;
  final void Function(Habit) onAdd;
  final void Function(String) onDelete;

  const HomeBody({
    super.key,
    required this.habits,
    required this.onToggle,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  Future<void> _addHabit() async {
    final result = await showModalBottomSheet<Habit>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddHabitSheet(),
    );
    if (result != null) widget.onAdd(result);
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
    });
  }

  String _monthName(int m) {
    const n = ['','يناير','فبراير','مارس','أبريل','مايو','يونيو',
        'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    return n[m];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.surfaceBg,
        body: Column(
          children: [
            Container(
              color: KhatwaTheme.primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MonthBtn(icon: Icons.chevron_right_rounded,
                      onTap: () => _changeMonth(-1)),
                  Text(
                    '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                    style: const TextStyle(color: Colors.white,
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  _MonthBtn(icon: Icons.chevron_left_rounded,
                      onTap: () => _changeMonth(1)),
                ],
              ),
            ),
            Expanded(
              child: widget.habits.isEmpty
                  ? _EmptyState(onAdd: _addHabit)
                  : ListView.builder(
                      padding: const EdgeInsets.all(14),
                      itemCount: widget.habits.length,
                      itemBuilder: (context, i) {
                        final habit = widget.habits[i];
                        return Dismissible(
                          key: Key(habit.id),
                          direction: DismissDirection.startToEnd,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.delete_outline_rounded,
                                color: Colors.red),
                          ),
                          onDismissed: (_) => widget.onDelete(habit.id),
                          child: HabitCard(
                            habit: habit,
                            year: _currentMonth.year,
                            month: _currentMonth.month,
                            onToggle: (d) => widget.onToggle(habit, d),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addHabit,
          backgroundColor: KhatwaTheme.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          icon: const Icon(Icons.add_rounded),
          label: const Text('عادة جديدة',
              style: TextStyle(fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}

class _MonthBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MonthBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: KhatwaTheme.primaryLight,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(child: Text('🚶', style: TextStyle(fontSize: 36))),
        ),
        const SizedBox(height: 16),
        const Text('ابدأ أول خطوة!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        const Text('أضف عادة وابدأ رحلتك',
            style: TextStyle(fontSize: 14, color: KhatwaTheme.textSecondary)),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: KhatwaTheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('أضف أول عادة'),
        ),
      ],
    ),
  );
}
