import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_colors.dart';

class CountRingButton extends StatefulWidget {
  const CountRingButton({
    super.key,
    required this.onTap,
    this.diameter = 176,
  });

  final VoidCallback onTap;
  final double diameter;

  @override
  State<CountRingButton> createState() => _CountRingButtonState();
}

class _CountRingButtonState extends State<CountRingButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'زيادة العداد',
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: SizedBox.square(
          dimension: widget.diameter,
          child: Material(
            type: MaterialType.transparency,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: const Color(0x22FFFFFF),
              highlightColor: const Color(0x10FFFFFF),
              onHighlightChanged: (pressed) => setState(() => _pressed = pressed),
              onTap: widget.onTap,
              child: CustomPaint(
                painter: const _CountRingPainter(),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountRingPainter extends CustomPainter {
  const _CountRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final dots = Paint()..color = AppColors.white;

    const rings = 4;
    final outer = radius - 2.4;
    final inner = radius * 0.80;
    for (var ring = 0; ring < rings; ring++) {
      final t = ring / (rings - 1);
      final ringRadius = inner + (outer - inner) * t;
      final count = math.max(24, (math.pi * 2 * ringRadius / 6.2).round());
      final phase = ring.isOdd ? math.pi / count : 0.0;
      for (var i = 0; i < count; i++) {
        final angle = phase + math.pi * 2 * i / count;
        canvas.drawCircle(
          center + Offset(math.cos(angle), math.sin(angle)) * ringRadius,
          1.45,
          dots,
        );
      }
    }

    canvas.drawCircle(
      center,
      radius * 0.66,
      Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
