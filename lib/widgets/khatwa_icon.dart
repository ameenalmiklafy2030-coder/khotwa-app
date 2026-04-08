import 'package:flutter/material.dart';
import 'dart:math' as math;

/// أيقونة القدم الواقعية لتطبيق خطوة
class KhatwaIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool withBackground;

  const KhatwaIcon({
    super.key,
    this.size = 40,
    this.color = const Color(0xFF1D9E75),
    this.withBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FootIconPainter(
          color: color,
          withBackground: withBackground,
        ),
      ),
    );
  }
}

class _FootIconPainter extends CustomPainter {
  final Color color;
  final bool withBackground;

  _FootIconPainter({required this.color, required this.withBackground});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 96.0; // scale factor — designed on 96×96 grid

    // --- خلفية مربعة بزوايا دائرية ---
    if (withBackground) {
      final bgPaint = Paint()..color = color;
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(22 * s),
      );
      canvas.drawRRect(bgRect, bgPaint);
    }

    final footPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // --- جسم القدم ---
    final bodyPath = Path();
    // نقطة البداية: أسفل الكعب
    bodyPath.moveTo(34 * s, 72 * s);
    bodyPath.cubicTo(
      26 * s, 72 * s,
      22 * s, 64 * s,
      22 * s, 55 * s,
    );
    bodyPath.cubicTo(
      22 * s, 43 * s,
      26 * s, 33 * s,
      34 * s, 29 * s,
    );
    bodyPath.cubicTo(
      39 * s, 27 * s,
      44 * s, 28 * s,
      47 * s, 33 * s,
    );
    bodyPath.cubicTo(
      50 * s, 38 * s,
      50 * s, 47 * s,
      49 * s, 55 * s,
    );
    bodyPath.cubicTo(
      48 * s, 62 * s,
      55 * s, 65 * s,
      60 * s, 60 * s,
    );
    bodyPath.cubicTo(
      62 * s, 57 * s,
      61 * s, 52 * s,
      61 * s, 51 * s,
    );
    bodyPath.cubicTo(
      63 * s, 48 * s,
      65 * s, 52 * s,
      64 * s, 57 * s,
    );
    bodyPath.cubicTo(
      62 * s, 64 * s,
      55 * s, 70 * s,
      47 * s, 71 * s,
    );
    bodyPath.cubicTo(
      42 * s, 72 * s,
      38 * s, 72 * s,
      34 * s, 72 * s,
    );
    bodyPath.close();

    canvas.drawPath(bodyPath, footPaint..color = Colors.white.withOpacity(0.95));

    // --- الأصابع الخمسة ---
    final toes = [
      // cx, cy, rx, ry, opacity
      [27.0, 25.0, 4.5, 5.5, 0.93],
      [35.0, 21.0, 4.5, 5.5, 0.93],
      [43.0, 22.5, 4.0, 5.0, 0.90],
      [50.0, 26.0, 3.5, 4.5, 0.85],
      [56.0, 32.0, 3.0, 4.0, 0.78],
    ];

    for (final toe in toes) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(toe[0] * s, toe[1] * s),
          width: toe[2] * 2 * s,
          height: toe[3] * 2 * s,
        ),
        footPaint..color = Colors.white.withOpacity(toe[4]),
      );
    }

    // --- خط القوس الخفيف ---
    final archPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 * s
      ..strokeCap = StrokeCap.round;

    final archPath = Path();
    archPath.moveTo(32 * s, 60 * s);
    archPath.quadraticBezierTo(36 * s, 63 * s, 40 * s, 60 * s);
    canvas.drawPath(archPath, archPaint);
  }

  @override
  bool shouldRepaint(_FootIconPainter old) =>
      old.color != color || old.withBackground != withBackground;
}
