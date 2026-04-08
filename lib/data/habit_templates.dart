// ── فئات العبادات والعادات الإسلامية الجاهزة ──

enum HabitCategory {
  worship,   // عبادات
  health,    // صحة
  learning,  // تعلم
  personal,  // شخصية
  custom,    // مخصصة
}

class HabitTemplate {
  final String id;
  final String title;
  final String icon;
  final String description;
  final HabitCategory category;
  final int targetDays; // 30 أو 66

  const HabitTemplate({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.category,
    this.targetDays = 66,
  });
}

// ── العبادات الإسلامية ──
const islamicTemplates = [
  HabitTemplate(
    id: 'fajr_jamaa',
    title: 'صلاة الفجر في جماعة',
    icon: '🌅',
    description: 'أدِّ صلاة الفجر مع الجماعة في المسجد',
    category: HabitCategory.worship,
  ),
  HabitTemplate(
    id: 'five_prayers',
    title: 'الصلوات الخمس في وقتها',
    icon: '🕌',
    description: 'حافظ على الصلوات الخمس في أوقاتها',
    category: HabitCategory.worship,
  ),
  HabitTemplate(
    id: 'quran_page',
    title: 'قراءة صفحة من القرآن',
    icon: '📖',
    description: 'اقرأ صفحة على الأقل من كتاب الله يومياً',
    category: HabitCategory.worship,
  ),
  HabitTemplate(
    id: 'quran_juz',
    title: 'حفظ ورد القرآن اليومي',
    icon: '🤲',
    description: 'التزم بوردك اليومي من القرآن الكريم',
    category: HabitCategory.worship,
  ),
  HabitTemplate(
    id: 'morning_adhkar',
    title: 'أذكار الصباح',
    icon: '☀️',
    description: 'أذكار الصباح بعد صلاة الفجر',
    category: HabitCategory.worship,
  ),
  HabitTemplate(
    id: 'evening_adhkar',
    title: 'أذكار المساء',
    icon: '🌙',
    description: 'أذكار المساء بعد صلاة العصر',
    category: HabitCategory.worship,
  ),
  HabitTemplate(
    id: 'monday_fasting',
    title: 'صيام الاثنين',
    icon: '🌟',
    description: 'صم يوم الاثنين اقتداءً بالنبي ﷺ',
    category: HabitCategory.worship,
  ),
  HabitTemplate(
    id: 'thursday_fasting',
    title: 'صيام الخميس',
    icon: '✨',
    description: 'صم يوم الخميس اقتداءً بالنبي ﷺ',
    category: HabitCategory.worship,
  ),
  HabitTemplate(
    id: 'white_days',
    title: 'صيام الأيام البيض',
    icon: '🌕',
    description: 'صيام 13 و14 و15 من كل شهر هجري',
    category: HabitCategory.worship,
  ),
  HabitTemplate(
    id: 'tahajjud',
    title: 'صلاة التهجد',
    icon: '🌃',
    description: 'قم من الليل وصلِّ ركعتين على الأقل',
    category: HabitCategory.worship,
  ),
  HabitTemplate(
    id: 'sadaqah',
    title: 'الصدقة اليومية',
    icon: '💝',
    description: 'تصدق بشيء ولو قليل كل يوم',
    category: HabitCategory.worship,
  ),
  HabitTemplate(
    id: 'istighfar',
    title: 'الاستغفار 100 مرة',
    icon: '🙏',
    description: 'قل أستغفر الله مئة مرة يومياً',
    category: HabitCategory.worship,
  ),
];

// ── الصحة والجسم ──
const healthTemplates = [
  HabitTemplate(
    id: 'walk_30',
    title: 'المشي 30 دقيقة',
    icon: '🚶',
    description: 'امشِ نصف ساعة يومياً للحفاظ على صحتك',
    category: HabitCategory.health,
  ),
  HabitTemplate(
    id: 'water_8',
    title: 'شرب 8 أكواب ماء',
    icon: '💧',
    description: 'اشرب ثمانية أكواب من الماء يومياً',
    category: HabitCategory.health,
  ),
  HabitTemplate(
    id: 'sleep_early',
    title: 'النوم المبكر',
    icon: '😴',
    description: 'نَم قبل الساعة 11 مساءً',
    category: HabitCategory.health,
  ),
  HabitTemplate(
    id: 'no_sugar',
    title: 'تجنب السكر',
    icon: '🥗',
    description: 'ابتعد عن السكريات المضافة اليوم',
    category: HabitCategory.health,
  ),
];

// ── التعلم والمعرفة ──
const learningTemplates = [
  HabitTemplate(
    id: 'read_book',
    title: 'قراءة كتاب 20 دقيقة',
    icon: '📚',
    description: 'اقرأ عشرين دقيقة من كتاب مفيد',
    category: HabitCategory.learning,
  ),
  HabitTemplate(
    id: 'journal',
    title: 'كتابة يومية',
    icon: '✍️',
    description: 'سجّل أفكارك وأهدافك يومياً',
    category: HabitCategory.learning,
  ),
  HabitTemplate(
    id: 'new_skill',
    title: 'تعلم مهارة جديدة',
    icon: '🎯',
    description: 'خصص وقتاً لتعلم شيء جديد كل يوم',
    category: HabitCategory.learning,
  ),
];

// كل القوالب مجمعة
const allTemplates = [
  ...islamicTemplates,
  ...healthTemplates,
  ...learningTemplates,
];
