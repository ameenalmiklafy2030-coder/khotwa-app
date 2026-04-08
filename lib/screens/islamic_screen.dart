import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/habit_templates.dart';
import '../models/habit.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class IslamicScreen extends StatefulWidget {
  const IslamicScreen({super.key});

  @override
  State<IslamicScreen> createState() => _IslamicScreenState();
}

class _IslamicScreenState extends State<IslamicScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  int _quranPage = 0;
  int _quranJuz = 1;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          // تبويبات
          Container(
            color: KhatwaTheme.primary,
            child: TabBar(
              controller: _tabs,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: Colors.white,
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'العبادات'),
                Tab(text: 'القرآن'),
                Tab(text: 'الصيام'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _WorshipTab(),
                _QuranTab(
                  currentPage: _quranPage,
                  currentJuz: _quranJuz,
                  onPageUpdate: (p) => setState(() => _quranPage = p),
                  onJuzUpdate: (j) => setState(() => _quranJuz = j),
                ),
                _FastingTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── تبويب العبادات ──
class _WorshipTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final activeIds = state.habits.map((h) => h.id).toSet();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // بانر تحفيزي
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: KhatwaTheme.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text('🌙', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('اجعل يومك عبادة',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: KhatwaTheme.primaryDark)),
                      Text('أضف عاداتك الإسلامية وتابع تقدمك',
                          style: TextStyle(
                              fontSize: 12,
                              color: KhatwaTheme.primaryDark)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // الصلوات الخمس — متابعة اليوم
          const Text('متابعة الصلوات',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: KhatwaTheme.textPrimary)),
          const SizedBox(height: 8),
          _PrayerTracker(),

          const SizedBox(height: 16),

          // قوالب جاهزة للإضافة
          const Text('عادات إسلامية جاهزة',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: KhatwaTheme.textPrimary)),
          const SizedBox(height: 8),

          ...islamicTemplates.map((tmpl) {
            final alreadyAdded = state.habits.any((h) => h.id == tmpl.id);
            return _TemplateCard(
              template: tmpl,
              alreadyAdded: alreadyAdded,
              onAdd: () async {
                if (!alreadyAdded) {
                  final habit = Habit(
                    id: tmpl.id,
                    title: tmpl.title,
                    icon: tmpl.icon,
                    createdAt: DateTime.now(),
                  );
                  await context.read<AppState>().addHabit(habit);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تمت إضافة: ${tmpl.title} ✓'),
                        backgroundColor: KhatwaTheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                }
              },
            );
          }),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ── متابع الصلوات الخمس ──
class _PrayerTracker extends StatefulWidget {
  @override
  State<_PrayerTracker> createState() => _PrayerTrackerState();
}

class _PrayerTrackerState extends State<_PrayerTracker> {
  final _prayers = [
    {'name': 'الفجر', 'icon': '🌅', 'done': false},
    {'name': 'الظهر', 'icon': '☀️', 'done': false},
    {'name': 'العصر', 'icon': '🌤️', 'done': false},
    {'name': 'المغرب', 'icon': '🌅', 'done': false},
    {'name': 'العشاء', 'icon': '🌙', 'done': false},
  ];

  @override
  Widget build(BuildContext context) {
    final doneCount = _prayers.where((p) => p['done'] == true).length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$doneCount/5 صلوات',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: KhatwaTheme.primary)),
              Text(
                doneCount == 5
                    ? '✨ اكتملت صلوات اليوم'
                    : 'تبقّى ${5 - doneCount}',
                style: const TextStyle(
                    fontSize: 11, color: KhatwaTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: doneCount / 5,
              minHeight: 5,
              backgroundColor: KhatwaTheme.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  KhatwaTheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _prayers.map((p) {
              final done = p['done'] as bool;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(
                      () => p['done'] = !(p['done'] as bool)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: done
                          ? KhatwaTheme.primary
                          : KhatwaTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: done
                            ? KhatwaTheme.primaryDark
                            : KhatwaTheme.border,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(p['icon'] as String,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(p['name'] as String,
                            style: TextStyle(
                                fontSize: 9,
                                color: done
                                    ? Colors.white
                                    : KhatwaTheme.textSecondary,
                                fontWeight: FontWeight.w500)),
                        if (done)
                          const Text('✓',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── تبويب القرآن ──
class _QuranTab extends StatelessWidget {
  final int currentPage;
  final int currentJuz;
  final ValueChanged<int> onPageUpdate;
  final ValueChanged<int> onJuzUpdate;

  const _QuranTab({
    required this.currentPage,
    required this.currentJuz,
    required this.onPageUpdate,
    required this.onJuzUpdate,
  });

  @override
  Widget build(BuildContext context) {
    const totalPages = 604;
    final pct = currentPage / totalPages;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // تقدم الختمة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: context.borderColor, width: 0.5),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('تقدم الختمة',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: KhatwaTheme.textPrimary)),
                    Text('${(pct * 100).round()}%',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: KhatwaTheme.primary)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: KhatwaTheme.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        KhatwaTheme.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الصفحة $currentPage',
                        style: const TextStyle(
                            fontSize: 12,
                            color: KhatwaTheme.textSecondary)),
                    Text('متبقي ${totalPages - currentPage} صفحة',
                        style: const TextStyle(
                            fontSize: 12,
                            color: KhatwaTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 14),
                // تحديث الصفحة
                Row(
                  children: [
                    const Text('الصفحة الحالية:',
                        style: TextStyle(
                            fontSize: 13,
                            color: KhatwaTheme.textSecondary)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Slider(
                        value: currentPage.toDouble(),
                        min: 0,
                        max: totalPages.toDouble(),
                        divisions: totalPages,
                        activeColor: KhatwaTheme.primary,
                        onChanged: (v) => onPageUpdate(v.round()),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text('$currentPage',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: KhatwaTheme.primary)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // الأجزاء
          Container(
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
                const Text('الجزء الحالي',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: KhatwaTheme.textPrimary)),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 1,
                  ),
                  itemCount: 30,
                  itemBuilder: (_, i) {
                    final juzNum = i + 1;
                    final done = juzNum < currentJuz;
                    final current = juzNum == currentJuz;
                    return GestureDetector(
                      onTap: () => onJuzUpdate(juzNum),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: done
                              ? KhatwaTheme.primary
                              : current
                                  ? KhatwaTheme.primaryLight
                                  : KhatwaTheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: current
                                ? KhatwaTheme.primary
                                : KhatwaTheme.border,
                            width: current ? 1.5 : 0.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$juzNum',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: done
                                  ? Colors.white
                                  : current
                                      ? KhatwaTheme.primary
                                      : KhatwaTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ── تبويب الصيام ──
class _FastingTab extends StatefulWidget {
  @override
  State<_FastingTab> createState() => _FastingTabState();
}

class _FastingTabState extends State<_FastingTab> {
  final Set<int> _mondayDones = {};
  final Set<int> _thursdayDones = {};

  // أيام الأسبوع في الشهر الحالي
  List<DateTime> _getDaysOfWeekday(int weekday) {
    final now = DateTime.now();
    final days = <DateTime>[];
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    for (var d = firstDay;
        d.isBefore(lastDay.add(const Duration(days: 1)));
        d = d.add(const Duration(days: 1))) {
      if (d.weekday == weekday) days.add(d);
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final mondays = _getDaysOfWeekday(DateTime.monday);
    final thursdays = _getDaysOfWeekday(DateTime.thursday);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // صيام الاثنين
          _FastingCard(
            title: 'صيام الاثنين',
            icon: '🌟',
            days: mondays,
            dones: _mondayDones,
            onToggle: (i) => setState(() =>
                _mondayDones.contains(i)
                    ? _mondayDones.remove(i)
                    : _mondayDones.add(i)),
          ),

          const SizedBox(height: 12),

          // صيام الخميس
          _FastingCard(
            title: 'صيام الخميس',
            icon: '✨',
            days: thursdays,
            dones: _thursdayDones,
            onToggle: (i) => setState(() =>
                _thursdayDones.contains(i)
                    ? _thursdayDones.remove(i)
                    : _thursdayDones.add(i)),
          ),

          const SizedBox(height: 12),

          // الأيام البيض
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
                Row(
                  children: const [
                    Text('🌕', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text('الأيام البيض',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: KhatwaTheme.textPrimary)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('13 و14 و15 من كل شهر هجري',
                    style: TextStyle(
                        fontSize: 12, color: KhatwaTheme.textSecondary)),
                const SizedBox(height: 12),
                Row(
                  children: [13, 14, 15].map((day) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: KhatwaTheme.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: KhatwaTheme.primary.withOpacity(0.3),
                              width: 0.5),
                        ),
                        child: Column(
                          children: [
                            Text('$day',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: KhatwaTheme.primary)),
                            const Text('هجري',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: KhatwaTheme.primaryDark)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _FastingCard extends StatelessWidget {
  final String title, icon;
  final List<DateTime> days;
  final Set<int> dones;
  final ValueChanged<int> onToggle;

  const _FastingCard({
    required this.title,
    required this.icon,
    required this.days,
    required this.dones,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: KhatwaTheme.textPrimary)),
              const Spacer(),
              Text('${dones.length}/${days.length}',
                  style: const TextStyle(
                      fontSize: 12, color: KhatwaTheme.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: days.asMap().entries.map((e) {
              final i = e.key;
              final day = e.value;
              final done = dones.contains(i);
              final isPast = day.isBefore(now);
              return Expanded(
                child: GestureDetector(
                  onTap: () => onToggle(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: done
                          ? KhatwaTheme.primary
                          : isPast
                              ? KhatwaTheme.surface
                              : KhatwaTheme.primaryLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: done
                            ? KhatwaTheme.primaryDark
                            : KhatwaTheme.border,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text('${day.day}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: done
                                    ? Colors.white
                                    : KhatwaTheme.textPrimary)),
                        if (done)
                          const Text('✓',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final HabitTemplate template;
  final bool alreadyAdded;
  final VoidCallback onAdd;

  const _TemplateCard({
    required this.template,
    required this.alreadyAdded,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alreadyAdded
              ? KhatwaTheme.primary.withOpacity(0.3)
              : context.borderColor,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: KhatwaTheme.primaryLight,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Text(template.icon,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: KhatwaTheme.textPrimary)),
                Text(template.description,
                    style: const TextStyle(
                        fontSize: 11,
                        color: KhatwaTheme.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          alreadyAdded
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: KhatwaTheme.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('مضافة ✓',
                      style: TextStyle(
                          fontSize: 11,
                          color: KhatwaTheme.primary,
                          fontWeight: FontWeight.w500)),
                )
              : GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: KhatwaTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add,
                        color: Colors.white, size: 16),
                  ),
                ),
        ],
      ),
    );
  }
}
