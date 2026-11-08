import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_colors.dart';

class KaabaIcon extends StatelessWidget {
  const KaabaIcon({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _KaabaPainter(),
    );
  }
}

class MenuIcon extends StatelessWidget {
  const MenuIcon({super.key, this.size = 26});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _MenuPainter(),
    );
  }
}

class ResetIcon extends StatelessWidget {
  const ResetIcon({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _ResetPainter(),
    );
  }
}

class WaveformIcon extends StatelessWidget {
  const WaveformIcon({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _WaveformPainter(),
    );
  }
}

class BookmarkIcon extends StatelessWidget {
  const BookmarkIcon({super.key, this.size = 32, this.filled = false});

  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _BookmarkPainter(filled: filled),
    );
  }
}

class ChevronIcon extends StatelessWidget {
  const ChevronIcon({super.key, required this.pointsRight, this.size = 22});

  final bool pointsRight;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ChevronPainter(pointsRight: pointsRight),
    );
  }
}

Paint _stroke(Size size, {double factor = 0.055}) {
  return Paint()
    ..color = AppColors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = size.shortestSide * factor
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
}

class _KaabaPainter extends CustomPainter {
  const _KaabaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = _stroke(size, factor: 0.045);
    final w = size.width;
    final h = size.height;

    final frontTopLeft = Offset(w * 0.08, h * 0.36);
    final frontTopRight = Offset(w * 0.60, h * 0.36);
    final frontBottomRight = Offset(w * 0.60, h * 0.90);
    final frontBottomLeft = Offset(w * 0.08, h * 0.90);
    final roofBackLeft = Offset(w * 0.30, h * 0.14);
    final roofBackRight = Offset(w * 0.90, h * 0.14);
    final sideBottom = Offset(w * 0.90, h * 0.66);

    final front = Path()
      ..moveTo(frontTopLeft.dx, frontTopLeft.dy)
      ..lineTo(frontTopRight.dx, frontTopRight.dy)
      ..lineTo(frontBottomRight.dx, frontBottomRight.dy)
      ..lineTo(frontBottomLeft.dx, frontBottomLeft.dy)
      ..close();
    final roof = Path()
      ..moveTo(frontTopLeft.dx, frontTopLeft.dy)
      ..lineTo(roofBackLeft.dx, roofBackLeft.dy)
      ..lineTo(roofBackRight.dx, roofBackRight.dy)
      ..lineTo(frontTopRight.dx, frontTopRight.dy)
      ..close();
    final side = Path()
      ..moveTo(frontTopRight.dx, frontTopRight.dy)
      ..lineTo(roofBackRight.dx, roofBackRight.dy)
      ..lineTo(sideBottom.dx, sideBottom.dy)
      ..lineTo(frontBottomRight.dx, frontBottomRight.dy)
      ..close();

    canvas.drawPath(roof, paint);
    canvas.drawPath(side, paint);
    canvas.drawPath(front, paint);

    final bandY = frontTopLeft.dy + (frontBottomLeft.dy - frontTopLeft.dy) * 0.16;
    final bandSideY = frontTopRight.dy + (sideBottom.dy - roofBackRight.dy) * 0.16;
    canvas.drawLine(
      Offset(frontTopLeft.dx, bandY),
      Offset(frontTopRight.dx, bandY),
      paint,
    );
    canvas.drawLine(
      Offset(frontTopRight.dx, bandY),
      Offset(
        frontTopRight.dx + (roofBackRight.dx - frontTopRight.dx) * 0.72,
        bandY + (bandSideY - bandY) * 0.72,
      ),
      paint,
    );

    final door = RRect.fromRectAndCorners(
      Rect.fromLTRB(w * 0.24, h * 0.56, w * 0.44, h * 0.90),
      topLeft: Radius.circular(w * 0.045),
      topRight: Radius.circular(w * 0.045),
    );
    canvas.drawRRect(door, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MenuPainter extends CustomPainter {
  const _MenuPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = _stroke(size, factor: 0.07);
    final left = size.width * 0.12;
    final right = size.width * 0.88;
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.24 + i * 0.26);
      canvas.drawLine(Offset(left, y), Offset(right, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ResetPainter extends CustomPainter {
  const _ResetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = _stroke(size, factor: 0.065);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.32;
    const start = -math.pi / 2 + 0.7;
    const sweep = -math.pi * 1.65;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      paint,
    );

    final endAngle = start + sweep;
    final end = center + Offset(math.cos(endAngle), math.sin(endAngle)) * radius;
    final direction = Offset(math.sin(endAngle), -math.cos(endAngle));
    final normal = Offset(-direction.dy, direction.dx);
    final tip = end + direction * size.width * 0.18;
    final base = end - direction * size.width * 0.02;
    final wing = size.width * 0.11;
    final arrow = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base.dx + normal.dx * wing, base.dy + normal.dy * wing)
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(base.dx - normal.dx * wing, base.dy - normal.dy * wing);
    canvas.drawPath(arrow, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter();

  static const _heights = <double>[
    0.28,
    0.46,
    0.68,
    0.9,
    0.52,
    1,
    0.52,
    0.9,
    0.68,
    0.46,
    0.28,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = _stroke(size, factor: 0.055);
    final count = _heights.length;
    final usable = size.width * 0.86;
    final step = usable / count;
    final left = (size.width - usable) / 2 + step / 2;
    final centerY = size.height / 2;
    final maxHeight = size.height * 0.72;

    for (var i = 0; i < count; i++) {
      final barHeight = maxHeight * _heights[i];
      final x = left + step * i;
      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BookmarkPainter extends CustomPainter {
  const _BookmarkPainter({required this.filled});

  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.28, size.height * 0.12)
      ..lineTo(size.width * 0.72, size.height * 0.12)
      ..lineTo(size.width * 0.72, size.height * 0.88)
      ..lineTo(size.width * 0.50, size.height * 0.68)
      ..lineTo(size.width * 0.28, size.height * 0.88)
      ..close();
    final paint = _stroke(size, factor: 0.06);
    if (filled) {
      canvas.drawPath(path, Paint()..color = AppColors.white);
      return;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BookmarkPainter oldDelegate) {
    return oldDelegate.filled != filled;
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.pointsRight});

  final bool pointsRight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = _stroke(size, factor: 0.075)..color = AppColors.chevron;
    final top = Offset(size.width * 0.34, size.height * 0.28);
    final middle = Offset(size.width * 0.66, size.height * 0.50);
    final bottom = Offset(size.width * 0.34, size.height * 0.72);
    final path = Path();
    if (pointsRight) {
      path
        ..moveTo(top.dx, top.dy)
        ..lineTo(middle.dx, middle.dy)
        ..lineTo(bottom.dx, bottom.dy);
    } else {
      path
        ..moveTo(size.width - top.dx, top.dy)
        ..lineTo(size.width - middle.dx, middle.dy)
        ..lineTo(size.width - bottom.dx, bottom.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) {
    return oldDelegate.pointsRight != pointsRight;
  }
}
