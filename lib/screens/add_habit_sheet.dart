import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

const _presetIcons = [
  '🕌', '📖', '🚶', '💧', '📚', '🏃', '🧘', '✍️',
  '🌙', '🤲', '🥗', '😴', '📝', '🎯', '💪', '🌿',
];

class AddHabitSheet extends StatefulWidget {
  const AddHabitSheet({super.key});

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final _controller = TextEditingController();
  String _selectedIcon = '🎯';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    final habit = Habit(
      id: const Uuid().v4(),
      title: title,
      icon: _selectedIcon,
      createdAt: DateTime.now(),
    );
    Navigator.pop(context, habit);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: KhatwaTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'إضافة عادة جديدة',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: KhatwaTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // حقل الاسم
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: _controller,
              autofocus: true,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 15,
                color: KhatwaTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'اسم العادة...',
                hintStyle:
                    const TextStyle(color: KhatwaTheme.textHint, fontSize: 14),
                filled: true,
                fillColor: KhatwaTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: KhatwaTheme.border, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: KhatwaTheme.border, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: KhatwaTheme.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // اختيار الأيقونة
          const Text(
            'اختر أيقونة',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              color: KhatwaTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: _presetIcons.map((icon) {
              final selected = icon == _selectedIcon;
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = icon),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? KhatwaTheme.primaryLight
                        : KhatwaTheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? KhatwaTheme.primary
                          : KhatwaTheme.border,
                      width: selected ? 1.5 : 0.5,
                    ),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 22)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // زر الإضافة
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: KhatwaTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'إضافة العادة',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
