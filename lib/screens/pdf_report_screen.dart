import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class PdfReportScreen extends StatefulWidget {
  const PdfReportScreen({super.key});

  @override
  State<PdfReportScreen> createState() => _PdfReportScreenState();
}

class _PdfReportScreenState extends State<PdfReportScreen> {
  bool _generating = false;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  static const _monthNames = [
    '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  Future<void> _generateAndShare() async {
    setState(() => _generating = true);
    try {
      final habits = context.read<AppState>().habits;
      final pdf = await _buildPdf(habits, _selectedYear, _selectedMonth);
      await Printing.sharePdf(
        bytes: pdf,
        filename:
            'تقرير-خطوة-${_monthNames[_selectedMonth]}-$_selectedYear.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التوليد: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<Uint8List> _buildPdf(
      List<Habit> habits, int year, int month) async {
    final pdf = pw.Document();
    final green = PdfColor.fromHex('1D9E75');
    final darkGreen = PdfColor.fromHex('0F6E56');
    final lightGreen = PdfColor.fromHex('E1F5EE');
    final gray = PdfColor.fromHex('6B7280');
    final lightGray = PdfColor.fromHex('F3F4F6');
    final border = PdfColor.fromHex('E5E7EB');

    // حساب الإحصائيات
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final totalPossible = habits.length * daysInMonth;
    final totalDone = habits.fold(
        0, (s, h) => s + h.completedInMonth(year, month));
    final overallPct = totalPossible > 0
        ? (totalDone / totalPossible * 100).round()
        : 0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [

          // ── رأس التقرير ──
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: green,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('خطوة',
                        style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                    pw.Text('تقرير العادات الشهري',
                        style: pw.TextStyle(
                            fontSize: 14,
                            color: PdfColors.white70)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('${_monthNames[month]} $year',
                        style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white)),
                    pw.Text('${habits.length} عادة نشطة',
                        style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.white70)),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ── بطاقات الملخص ──
          pw.Row(
            children: [
              _pdfStatCard('الإنجاز الكلي', '$overallPct%', green),
              pw.SizedBox(width: 10),
              _pdfStatCard('أيام منجزة', '$totalDone يوم', darkGreen),
              pw.SizedBox(width: 10),
              _pdfStatCard('أيام الشهر', '$daysInMonth يوم',
                  PdfColor.fromHex('378ADD')),
            ],
          ),

          pw.SizedBox(height: 20),

          // ── تفاصيل كل عادة ──
          pw.Text('تفاصيل العادات',
              style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('1A1A1A'))),
          pw.SizedBox(height: 10),

          ...habits.map((h) {
            final done = h.completedInMonth(year, month);
            final pct = daysInMonth > 0
                ? (done / daysInMonth * 100).round()
                : 0;

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                border:
                    pw.Border.all(color: border, width: 0.5),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('${h.icon}  ${h.title}',
                          style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold)),
                      pw.Text('$done/$daysInMonth يوم ($pct%)',
                          style: pw.TextStyle(
                              fontSize: 12, color: green)),
                    ],
                  ),
                  pw.SizedBox(height: 8),

                  // شريط التقدم
                  pw.Container(
                    height: 8,
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('E5E7EB'),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.FractionallySizedBox(
                      widthFactor: done / daysInMonth,
                      child: pw.Container(
                        decoration: pw.BoxDecoration(
                          color: pct >= 80
                              ? green
                              : pct >= 50
                                  ? PdfColor.fromHex('EF9F27')
                                  : PdfColor.fromHex('F09595'),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 8),

                  // شبكة الأيام
                  pw.Wrap(
                    spacing: 3,
                    runSpacing: 3,
                    children: List.generate(daysInMonth, (i) {
                      final day = i + 1;
                      final date = DateTime(year, month, day);
                      final isDone = h.isDoneOn(date);
                      return pw.Container(
                        width: 14,
                        height: 14,
                        decoration: pw.BoxDecoration(
                          color: isDone ? green : lightGray,
                          borderRadius: pw.BorderRadius.circular(2),
                        ),
                        child: isDone
                            ? pw.Center(
                                child: pw.Text('✓',
                                    style: pw.TextStyle(
                                        fontSize: 8,
                                        color: PdfColors.white)))
                            : null,
                      );
                    }),
                  ),
                ],
              ),
            );
          }).toList(),

          pw.SizedBox(height: 20),

          // ── تذييل التقرير ──
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: lightGreen,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('👣  تطبيق خطوة — كل يوم خطوة نحو الأفضل',
                    style: pw.TextStyle(
                        fontSize: 12,
                        color: darkGreen,
                        fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfStatCard(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(
                    fontSize: 11, color: PdfColors.white70)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<AppState>().habits;
    final daysInMonth =
        DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    final totalDone = habits.fold(
        0, (s, h) => s + h.completedInMonth(_selectedYear, _selectedMonth));
    final totalPossible = habits.length * daysInMonth;
    final pct = totalPossible > 0
        ? (totalDone / totalPossible * 100).round()
        : 0;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // معاينة التقرير
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: KhatwaTheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('📄',
                      style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  const Text('تقرير شهري PDF',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    '${_monthNames[_selectedMonth]} $_selectedYear',
                    style: const TextStyle(
                        fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),

                  // اختيار الشهر
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          if (_selectedMonth == 1) {
                            _selectedMonth = 12;
                            _selectedYear--;
                          } else {
                            _selectedMonth--;
                          }
                        }),
                        icon: const Icon(Icons.chevron_right_rounded,
                            color: Colors.white),
                      ),
                      Text(
                        '${_monthNames[_selectedMonth]} $_selectedYear',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          if (_selectedMonth == 12) {
                            _selectedMonth = 1;
                            _selectedYear++;
                          } else {
                            _selectedMonth++;
                          }
                        }),
                        icon: const Icon(Icons.chevron_left_rounded,
                            color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: _generating ? null : _generateAndShare,
                    icon: _generating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: KhatwaTheme.primary))
                        : const Icon(Icons.download_rounded, size: 18),
                    label: Text(
                        _generating ? 'جاري التوليد...' : 'توليد ومشاركة PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: KhatwaTheme.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // إحصائيات سريعة للشهر المختار
            Row(
              children: [
                _StatCard(
                    label: 'الإنجاز الكلي',
                    value: '$pct%',
                    icon: '📊'),
                const SizedBox(width: 10),
                _StatCard(
                    label: 'أيام منجزة',
                    value: '$totalDone',
                    icon: '✅'),
                const SizedBox(width: 10),
                _StatCard(
                    label: 'العادات',
                    value: '${habits.length}',
                    icon: '👣'),
              ],
            ),

            const SizedBox(height: 14),

            // معاينة بسيطة
            const Text('معاينة التقرير',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: KhatwaTheme.textPrimary)),
            const SizedBox(height: 8),

            ...habits.map((h) {
              final done = h.completedInMonth(_selectedYear, _selectedMonth);
              final pct2 = daysInMonth > 0
                  ? (done / daysInMonth * 100).round()
                  : 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: context.borderColor, width: 0.5),
                ),
                child: Row(
                  children: [
                    Text(h.icon,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.title,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: KhatwaTheme.textPrimary)),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: daysInMonth > 0
                                  ? done / daysInMonth
                                  : 0,
                              minHeight: 5,
                              backgroundColor: KhatwaTheme.border,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  pct2 >= 80
                                      ? KhatwaTheme.primary
                                      : pct2 >= 50
                                          ? const Color(0xFFBA7517)
                                          : Colors.red.shade300),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('$pct2%',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: KhatwaTheme.primary)),
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

class _StatCard extends StatelessWidget {
  final String label, value, icon;
  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderColor, width: 0.5),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: KhatwaTheme.primary)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: KhatwaTheme.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
