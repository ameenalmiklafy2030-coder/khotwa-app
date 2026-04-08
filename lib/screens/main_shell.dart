import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/khatwa_icon.dart';
import '../services/notification_service.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'achievements_screen.dart';
import 'reminders_screen.dart';
import 'profile_screen.dart';
import 'islamic_screen.dart';
import 'challenges_screen.dart';
import 'sixty_days_screen.dart';
import 'pdf_report_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0; // التبويبات الرئيسية 0-4

  // الصفحات الثانوية (من الدرج)
  bool _showIslamic = false;
  bool _showChallenges = false;
  bool _showSixtyDays = false;
  bool _showPdf = false;

  @override
  void initState() {
    super.initState();
    NotificationService().initialize();
  }

  final _titles = ['العادات','الإحصائيات','الإنجازات','التذكيرات','الملف'];

  String get _currentTitle {
    if (_showIslamic) return 'العبادات الإسلامية';
    if (_showChallenges) return 'التحديات';
    if (_showSixtyDays) return 'نمط 66 يوم';
    if (_showPdf) return 'تقرير PDF';
    return _titles[_tab];
  }

  bool get _showingExtra =>
      _showIslamic || _showChallenges || _showSixtyDays || _showPdf;

  void _closeExtra() => setState(() {
        _showIslamic = false;
        _showChallenges = false;
        _showSixtyDays = false;
        _showPdf = false;
      });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: KhatwaTheme.primary)),
      );
    }
    final habits = state.habits;
    final today = DateTime.now();
    final doneToday = habits.where((h) => h.isDoneOn(today)).length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: KhatwaTheme.primary,
          elevation: 0,
          leading: _showingExtra
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white, size: 20),
                  onPressed: _closeExtra,
                )
              : null,
          title: Row(
            children: [
              if (!_showingExtra) ...[
                const KhatwaIcon(size: 30),
                const SizedBox(width: 8),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('خطوة',
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 0.5)),
                  Text(_currentTitle,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.8))),
                ],
              ),
              const Spacer(),
              if (!_showingExtra && _tab == 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$doneToday/${habits.length} اليوم',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ),
            ],
          ),
          actions: [
            if (!_showingExtra)
              PopupMenuButton<String>(
                icon: const Icon(Icons.apps_rounded, color: Colors.white),
                color: context.cardBg,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (v) => setState(() {
                  _showIslamic = v == 'islamic';
                  _showChallenges = v == 'challenges';
                  _showSixtyDays = v == 'sixty';
                  _showPdf = v == 'pdf';
                }),
                itemBuilder: (_) => [
                  _menuItem('islamic', '🕌', 'العبادات الإسلامية'),
                  _menuItem('challenges', '🤝', 'تحديات الأصدقاء'),
                  _menuItem('sixty', '🧠', 'نمط 66 يوم'),
                  _menuItem('pdf', '📄', 'تقرير PDF'),
                ],
              ),
          ],
        ),
        body: _showingExtra
            ? _buildExtra()
            : IndexedStack(
                index: _tab,
                children: [
                  HomeBody(
                    habits: habits,
                    onToggle: (h, d) => state.toggleDay(h, d),
                    onAdd: (h) => state.addHabit(h),
                    onDelete: (id) => state.deleteHabit(id),
                  ),
                  StatsScreen(habits: habits),
                  AchievementsScreen(habits: habits),
                  RemindersScreen(habits: habits),
                  const ProfileScreen(),
                ],
              ),
        bottomNavigationBar: _showingExtra
            ? null
            : BottomNavigationBar(
                currentIndex: _tab,
                onTap: (i) => setState(() => _tab = i),
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 10,
                unselectedFontSize: 10,
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.grid_view_rounded, size: 22),
                      label: 'العادات'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.bar_chart_rounded, size: 22),
                      label: 'الإحصائيات'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.emoji_events_outlined, size: 22),
                      activeIcon: Icon(Icons.emoji_events_rounded, size: 22),
                      label: 'الإنجازات'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.notifications_outlined, size: 22),
                      activeIcon: Icon(Icons.notifications_rounded, size: 22),
                      label: 'التذكيرات'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline_rounded, size: 22),
                      activeIcon: Icon(Icons.person_rounded, size: 22),
                      label: 'الملف'),
                ],
              ),
      ),
    );
  }

  Widget _buildExtra() {
    if (_showIslamic) return const IslamicScreen();
    if (_showChallenges) return const ChallengesScreen();
    if (_showSixtyDays) return const SixtyDaysScreen();
    if (_showPdf) return const PdfReportScreen();
    return const SizedBox.shrink();
  }

  PopupMenuItem<String> _menuItem(String val, String icon, String label) =>
      PopupMenuItem<String>(
        value: val,
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(
                    fontSize: 13, color: KhatwaTheme.textPrimary)),
          ],
        ),
      );
}
