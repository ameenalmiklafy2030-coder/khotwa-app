import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/habit_templates.dart';
import '../models/habit.dart';
import '../models/user_profile.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/khatwa_icon.dart';
import 'main_shell.dart';

// ── نقطة دخول الـ Onboarding ──
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // بيانات المستخدم المُجمَّعة عبر الخطوات
  String _userName = '';
  String _avatarEmoji = '👤';
  String _themeMode = 'system';
  int _targetDays = 66;
  final Set<String> _selectedTemplateIds = {};

  final int _totalPages = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    final state = context.read<AppState>();

    // 1. حفظ الملف الشخصي
    final profile = UserProfile.newUser(_userName.isEmpty ? 'مستخدم خطوة' : _userName)
        .copyWith(avatarEmoji: _avatarEmoji, themeMode: _themeMode);
    await state.saveProfile(profile);

    // 2. إضافة العادات المختارة
    for (final tmpl in allTemplates) {
      if (_selectedTemplateIds.contains(tmpl.id)) {
        final habit = Habit(
          id: tmpl.id,
          title: tmpl.title,
          icon: tmpl.icon,
          createdAt: DateTime.now(),
        );
        await state.addHabit(habit);
      }
    }

    // 3. الانتقال للتطبيق
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: KhatwaTheme.primary,
        body: SafeArea(
          child: Column(
            children: [
              // شريط التقدم العلوي
              _TopBar(
                current: _currentPage,
                total: _totalPages,
                onBack: _currentPage > 0 ? _prevPage : null,
              ),

              // محتوى الصفحات
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    // صفحة 0: الترحيب
                    _WelcomePage(onNext: _nextPage),

                    // صفحة 1: الاسم والأفاتار
                    _NamePage(
                      initialName: _userName,
                      initialEmoji: _avatarEmoji,
                      onNext: (name, emoji) {
                        setState(() {
                          _userName = name;
                          _avatarEmoji = emoji;
                        });
                        _nextPage();
                      },
                    ),

                    // صفحة 2: اختيار الهدف (30 أو 66 يوم)
                    _GoalPage(
                      selected: _targetDays,
                      onNext: (days) {
                        setState(() => _targetDays = days);
                        _nextPage();
                      },
                    ),

                    // صفحة 3: اختيار العادات
                    _HabitsPage(
                      selectedIds: _selectedTemplateIds,
                      onToggle: (id) => setState(() {
                        if (_selectedTemplateIds.contains(id)) {
                          _selectedTemplateIds.remove(id);
                        } else {
                          _selectedTemplateIds.add(id);
                        }
                      }),
                      onNext: _nextPage,
                    ),

                    // صفحة 4: المظهر + الإنهاء
                    _ThemePage(
                      selected: _themeMode,
                      onSelect: (m) => setState(() => _themeMode = m),
                      onFinish: _finish,
                      selectedCount: _selectedTemplateIds.length,
                      userName: _userName,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── شريط التقدم العلوي ──
class _TopBar extends StatelessWidget {
  final int current, total;
  final VoidCallback? onBack;
  const _TopBar(
      {required this.current, required this.total, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // زر الرجوع
          AnimatedOpacity(
            opacity: onBack != null ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // أشرطة التقدم
          Expanded(
            child: Row(
              children: List.generate(total, (i) {
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i <= current
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          // رقم الخطوة
          Text('${current + 1}/$total',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8))),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════
// صفحة 0 — الترحيب
// ════════════════════════════════════════
class _WelcomePage extends StatefulWidget {
  final VoidCallback onNext;
  const _WelcomePage({required this.onNext});

  @override
  State<_WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<_WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الأيقونة الكبيرة
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: KhatwaIcon(size: 80, withBackground: false,
                      color: Colors.white),
                ),
              ),

              const SizedBox(height: 32),

              const Text('خطوة',
                  style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 2)),

              const SizedBox(height: 12),

              Text(
                'كل يوم خطوة نحو الأفضل',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4),
              ),

              const SizedBox(height: 16),

              Text(
                'تطبيق عربي أصيل لبناء العادات الجيدة\nمبني على علم النفس السلوكي',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.6),
              ),

              const SizedBox(height: 48),

              // ميزات سريعة
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FeaturePill('🕌 عبادات'),
                  const SizedBox(width: 8),
                  _FeaturePill('📊 إحصائيات'),
                  const SizedBox(width: 8),
                  _FeaturePill('🤝 تحديات'),
                ],
              ),

              const SizedBox(height: 48),

              // زر البدء
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: KhatwaTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('ابدأ رحلتك',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String text;
  const _FeaturePill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
    );
  }
}

// ════════════════════════════════════════
// صفحة 1 — الاسم والأفاتار
// ════════════════════════════════════════
class _NamePage extends StatefulWidget {
  final String initialName, initialEmoji;
  final void Function(String name, String emoji) onNext;
  const _NamePage(
      {required this.initialName,
      required this.initialEmoji,
      required this.onNext});

  @override
  State<_NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<_NamePage> {
  late TextEditingController _ctrl;
  late String _emoji;

  final _emojis = [
    '👤','🧑','👨','👩','🧔','👱','🧕','🙋',
    '💪','🦸','🌟','🔥','👣','🎯','🏃','🧘',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
    _emoji = widget.initialEmoji;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _PageWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _PageHeader(
            icon: '👋',
            title: 'أهلاً بك!',
            subtitle: 'أخبرنا عن نفسك لنجعل التجربة شخصية',
          ),

          const SizedBox(height: 28),

          // الأفاتار المختار
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(_emoji,
                    style: const TextStyle(fontSize: 44)),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // شبكة الأفاتار
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: _emojis.map((e) {
                final sel = e == _emoji;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _emoji = e);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: sel ? Colors.white : Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(e,
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // حقل الاسم
          TextField(
            controller: _ctrl,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'اسمك...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.3), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),

          const Spacer(),

          _NextButton(
            onTap: () => widget.onNext(_ctrl.text.trim(), _emoji),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════
// صفحة 2 — الهدف (30 أو 66 يوم)
// ════════════════════════════════════════
class _GoalPage extends StatelessWidget {
  final int selected;
  final void Function(int) onNext;
  const _GoalPage({required this.selected, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _PageWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _PageHeader(
            icon: '🎯',
            title: 'اختر هدفك',
            subtitle: 'كم يوماً تريد الالتزام؟',
          ),

          const SizedBox(height: 28),

          // خيار 30 يوم
          _GoalCard(
            days: 30,
            title: 'شهر واحد',
            badge: 'للمبتدئين',
            badgeColor: const Color(0xFF378ADD),
            description: 'ابدأ بخطوة بسيطة وثابتة',
            points: const [
              'مناسب لمن يبدأ رحلته',
              'أسهل في الاستمرار',
              'يبني الثقة بالنفس',
            ],
            selected: selected == 30,
            onTap: () => onNext(30),
          ),

          const SizedBox(height: 12),

          // خيار 66 يوم
          _GoalCard(
            days: 66,
            title: 'نمط العلماء',
            badge: 'مثبت علمياً ⭐',
            badgeColor: KhatwaTheme.primaryDark,
            description: 'الرقم الحقيقي لتكوين العادة',
            points: const [
              'مبني على بحث UCL 2010',
              'يجعل العادة تلقائية',
              'تأثير عميق ودائم',
            ],
            selected: selected == 66,
            onTap: () => onNext(66),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final int days;
  final String title, badge, description;
  final Color badgeColor;
  final List<String> points;
  final bool selected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.days,
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.description,
    required this.points,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withOpacity(0.2),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // رقم الأيام
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: selected
                    ? KhatwaTheme.primaryLight
                    : Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$days',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? KhatwaTheme.primary
                              : Colors.white)),
                  Text('يوم',
                      style: TextStyle(
                          fontSize: 10,
                          color: selected
                              ? KhatwaTheme.primaryDark
                              : Colors.white70)),
                ],
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? KhatwaTheme.textPrimary
                                  : Colors.white)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: selected
                              ? badgeColor.withOpacity(0.15)
                              : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(badge,
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: selected ? badgeColor : Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ...points.map((p) => Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded,
                                size: 12,
                                color: selected
                                    ? KhatwaTheme.primary
                                    : Colors.white60),
                            const SizedBox(width: 5),
                            Text(p,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: selected
                                        ? KhatwaTheme.textSecondary
                                        : Colors.white70)),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? KhatwaTheme.primary : Colors.white38,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
// صفحة 3 — اختيار العادات
// ════════════════════════════════════════
class _HabitsPage extends StatefulWidget {
  final Set<String> selectedIds;
  final void Function(String) onToggle;
  final VoidCallback onNext;
  const _HabitsPage({
    required this.selectedIds,
    required this.onToggle,
    required this.onNext,
  });

  @override
  State<_HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<_HabitsPage> {
  int _activeCategory = 0; // 0=كل, 1=عبادات, 2=صحة, 3=تعلم

  List<HabitTemplate> get _filtered {
    switch (_activeCategory) {
      case 1: return islamicTemplates;
      case 2: return healthTemplates;
      case 3: return learningTemplates;
      default: return allTemplates;
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.selectedIds.length;
    return _PageWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(
            icon: '✨',
            title: 'اختر عاداتك',
            subtitle: count > 0
                ? 'اخترت $count عادة — يمكنك إضافة المزيد لاحقاً'
                : 'اختر عادة واحدة على الأقل للبدء',
          ),

          const SizedBox(height: 14),

          // فلتر الفئات
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CategoryChip(label: 'الكل', selected: _activeCategory == 0,
                    onTap: () => setState(() => _activeCategory = 0)),
                _CategoryChip(label: '🕌 عبادات', selected: _activeCategory == 1,
                    onTap: () => setState(() => _activeCategory = 1)),
                _CategoryChip(label: '💪 صحة', selected: _activeCategory == 2,
                    onTap: () => setState(() => _activeCategory = 2)),
                _CategoryChip(label: '📚 تعلم', selected: _activeCategory == 3,
                    onTap: () => setState(() => _activeCategory = 3)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // قائمة العادات
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final tmpl = _filtered[i];
                final selected = widget.selectedIds.contains(tmpl.id);
                return _HabitTemplateCard(
                  template: tmpl,
                  selected: selected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onToggle(tmpl.id);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          _NextButton(
            label: count > 0 ? 'التالي ($count عادات)' : 'تخطي الآن',
            onTap: widget.onNext,
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color:
                    selected ? KhatwaTheme.primary : Colors.white)),
      ),
    );
  }
}

class _HabitTemplateCard extends StatelessWidget {
  final HabitTemplate template;
  final bool selected;
  final VoidCallback onTap;
  const _HabitTemplateCard(
      {required this.template, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // أيقونة
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? KhatwaTheme.primaryLight
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(template.icon,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),

            // النص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(template.title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? KhatwaTheme.textPrimary
                              : Colors.white)),
                  const SizedBox(height: 2),
                  Text(template.description,
                      style: TextStyle(
                          fontSize: 11,
                          color: selected
                              ? KhatwaTheme.textSecondary
                              : Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),

            // مؤشر الاختيار
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected
                    ? KhatwaTheme.primary
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? KhatwaTheme.primary : Colors.white38,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
// صفحة 4 — المظهر + الإنهاء
// ════════════════════════════════════════
class _ThemePage extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;
  final VoidCallback onFinish;
  final int selectedCount;
  final String userName;

  const _ThemePage({
    required this.selected,
    required this.onSelect,
    required this.onFinish,
    required this.selectedCount,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final name = userName.isEmpty ? 'صديقي' : userName;
    return _PageWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(
            icon: '🎨',
            title: 'اختر مظهرك',
            subtitle: 'يمكنك تغييره في أي وقت من الإعدادات',
          ),

          const SizedBox(height: 28),

          // خيارات المظهر
          _ThemeOption(
            icon: Icons.brightness_auto_rounded,
            title: 'تلقائي',
            subtitle: 'يتبع إعداد جهازك',
            selected: selected == 'system',
            onTap: () => onSelect('system'),
          ),
          const SizedBox(height: 10),
          _ThemeOption(
            icon: Icons.light_mode_rounded,
            title: 'فاتح',
            subtitle: 'خلفية بيضاء ناصعة',
            selected: selected == 'light',
            onTap: () => onSelect('light'),
          ),
          const SizedBox(height: 10),
          _ThemeOption(
            icon: Icons.dark_mode_rounded,
            title: 'داكن',
            subtitle: 'مريح للعينين ليلاً',
            selected: selected == 'dark',
            onTap: () => onSelect('dark'),
          ),

          const Spacer(),

          // ملخص قبل البدء
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text('أنت جاهز يا $name! 🚀',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  selectedCount > 0
                      ? 'ستبدأ بـ $selectedCount عادات — كل يوم خطوة صغيرة تصنع فارقاً كبيراً'
                      : 'ستبدأ بعادات افتراضية — أضف المزيد متى شئت',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // زر البدء
          ElevatedButton(
            onPressed: onFinish,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: KhatwaTheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('ابدأ رحلتي 👣',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? KhatwaTheme.primaryLight
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: selected ? KhatwaTheme.primary : Colors.white,
                  size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? KhatwaTheme.textPrimary
                              : Colors.white)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11,
                          color: selected
                              ? KhatwaTheme.textSecondary
                              : Colors.white70)),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? KhatwaTheme.primary : Colors.white38,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
// مكونات مشتركة
// ════════════════════════════════════════

class _PageWrapper extends StatelessWidget {
  final Widget child;
  const _PageWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: child,
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String icon, title, subtitle;
  const _PageHeader(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        const SizedBox(height: 6),
        Text(subtitle,
            style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                height: 1.4)),
      ],
    );
  }
}

class _NextButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NextButton({this.label = 'التالي', required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: KhatwaTheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      child: Text(label,
          style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
}
