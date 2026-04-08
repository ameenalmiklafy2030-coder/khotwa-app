import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';

// ── نموذج التحدي ──
class Challenge {
  final String id;
  final String title;
  final String icon;
  final String creatorName;
  final int targetDays;
  final DateTime startDate;
  final List<ChallengeParticipant> participants;

  Challenge({
    required this.id,
    required this.title,
    required this.icon,
    required this.creatorName,
    this.targetDays = 30,
    required this.startDate,
    required this.participants,
  });

  int get daysPassed =>
      DateTime.now().difference(startDate).inDays.clamp(0, targetDays);
  double get progress => daysPassed / targetDays;
}

class ChallengeParticipant {
  final String name;
  final String emoji;
  final int completedDays;
  const ChallengeParticipant({
    required this.name,
    required this.emoji,
    required this.completedDays,
  });
}

// ── بيانات تجريبية ──
final _demoChallenge = Challenge(
  id: '1',
  title: 'صلاة الفجر في جماعة',
  icon: '🌅',
  creatorName: 'أنت',
  targetDays: 30,
  startDate: DateTime.now().subtract(const Duration(days: 12)),
  participants: const [
    ChallengeParticipant(name: 'أنت', emoji: '👤', completedDays: 10),
    ChallengeParticipant(name: 'أحمد', emoji: '🧔', completedDays: 12),
    ChallengeParticipant(name: 'سارة', emoji: '👩', completedDays: 8),
    ChallengeParticipant(name: 'محمد', emoji: '👱', completedDays: 11),
  ],
);

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  final _challenges = [_demoChallenge];

  Future<void> _showCreateSheet() async {
    final result = await showModalBottomSheet<Challenge>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreateChallengeSheet(),
    );
    if (result != null) {
      setState(() => _challenges.add(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.surfaceBg,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // بطاقة دعوة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: KhatwaTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('🤝',
                        style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 8),
                    const Text('تحدَّ أصدقاءك وعائلتك',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      'المساءلة الجماعية تزيد نسبة النجاح إلى 95%',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _showCreateSheet,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('إنشاء تحدٍّ جديد'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: KhatwaTheme.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (_challenges.isNotEmpty) ...[
                const Text('تحدياتك النشطة',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: KhatwaTheme.textPrimary)),
                const SizedBox(height: 8),
                ..._challenges
                    .map((c) => _ChallengeCard(challenge: c))
                    .toList(),
              ],

              const SizedBox(height: 16),

              // كود الدعوة
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
                    const Text('انضم لتحدٍّ',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: KhatwaTheme.textPrimary)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            textDirection: TextDirection.ltr,
                            decoration: InputDecoration(
                              hintText: 'أدخل كود التحدي...',
                              filled: true,
                              fillColor: context.surfaceBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: context.borderColor,
                                    width: 0.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: context.borderColor,
                                    width: 0.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KhatwaTheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('انضم'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

// ── بطاقة التحدي ──
class _ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  const _ChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final sorted = [...challenge.participants]
      ..sort((a, b) => b.completedDays.compareTo(a.completedDays));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس التحدي
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: KhatwaTheme.primaryLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(challenge.icon,
                      style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(challenge.title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: KhatwaTheme.textPrimary)),
                    Text(
                        'يوم ${challenge.daysPassed} من ${challenge.targetDays}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: KhatwaTheme.textSecondary)),
                  ],
                ),
              ),
              // زر المشاركة
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('تم نسخ رابط التحدي 🔗'),
                      backgroundColor: KhatwaTheme.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                icon: const Icon(Icons.share_rounded,
                    size: 18, color: KhatwaTheme.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // شريط التقدم
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: challenge.progress,
              minHeight: 5,
              backgroundColor: KhatwaTheme.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  KhatwaTheme.primary),
            ),
          ),

          const SizedBox(height: 12),

          // لوحة المتصدرين
          const Text('لوحة المتصدرين',
              style: TextStyle(
                  fontSize: 12,
                  color: KhatwaTheme.textSecondary)),
          const SizedBox(height: 8),
          ...sorted.asMap().entries.map((e) {
            final rank = e.key + 1;
            final p = e.value;
            final isYou = p.name == 'أنت';
            final medals = ['🥇', '🥈', '🥉'];
            return Container(
              margin: const EdgeInsets.only(bottom: 5),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isYou
                    ? KhatwaTheme.primaryLight
                    : context.surfaceBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isYou
                      ? KhatwaTheme.primary.withOpacity(0.3)
                      : context.borderColor,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Text(rank <= 3 ? medals[rank - 1] : '$rank',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(p.emoji,
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(p.name,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: isYou
                                ? FontWeight.w500
                                : FontWeight.normal,
                            color: isYou
                                ? KhatwaTheme.primary
                                : KhatwaTheme.textPrimary)),
                  ),
                  Text('${p.completedDays} يوم',
                      style: const TextStyle(
                          fontSize: 12, color: KhatwaTheme.textSecondary)),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: p.completedDays / challenge.targetDays,
                        minHeight: 4,
                        backgroundColor: KhatwaTheme.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            isYou
                                ? KhatwaTheme.primary
                                : KhatwaTheme.textHint),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

// ── ورقة إنشاء تحدٍّ ──
class _CreateChallengeSheet extends StatefulWidget {
  const _CreateChallengeSheet();

  @override
  State<_CreateChallengeSheet> createState() =>
      _CreateChallengeSheetState();
}

class _CreateChallengeSheetState extends State<_CreateChallengeSheet> {
  final _nameCtrl = TextEditingController();
  String _icon = '🎯';
  int _days = 30;
  final _icons = ['🎯','🌅','🕌','📖','🚶','💧','🔥','💪','🌙','✨'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: KhatwaTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('إنشاء تحدٍّ جديد',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: KhatwaTheme.textPrimary)),
            const SizedBox(height: 16),

            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: 'اسم التحدي...',
                filled: true,
                fillColor: KhatwaTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: KhatwaTheme.border, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: KhatwaTheme.border, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: KhatwaTheme.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8, runSpacing: 8,
              children: _icons.map((e) {
                final sel = e == _icon;
                return GestureDetector(
                  onTap: () => setState(() => _icon = e),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: sel
                          ? KhatwaTheme.primaryLight
                          : KhatwaTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? KhatwaTheme.primary : KhatwaTheme.border,
                        width: sel ? 1.5 : 0.5,
                      ),
                    ),
                    child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Text('المدة:',
                    style: TextStyle(
                        fontSize: 13, color: KhatwaTheme.textSecondary)),
                Expanded(
                  child: Slider(
                    value: _days.toDouble(),
                    min: 7, max: 66, divisions: 59,
                    activeColor: KhatwaTheme.primary,
                    onChanged: (v) => setState(() => _days = v.round()),
                  ),
                ),
                Text('$_days يوم',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: KhatwaTheme.primary)),
              ],
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(context, Challenge(
                  id: const Uuid().v4(),
                  title: _nameCtrl.text.trim(),
                  icon: _icon,
                  creatorName: 'أنت',
                  targetDays: _days,
                  startDate: DateTime.now(),
                  participants: const [
                    ChallengeParticipant(
                        name: 'أنت', emoji: '👤', completedDays: 0),
                  ],
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: KhatwaTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('إنشاء التحدي ومشاركة الرابط',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}
