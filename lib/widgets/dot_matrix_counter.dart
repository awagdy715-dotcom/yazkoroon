import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Four-digit (or wider) counter drawn as separated circular dots.
class DotMatrixCounter extends StatelessWidget {
  const DotMatrixCounter({
    super.key,
    required this.value,
    this.digitWidth = 62,
  });

  final int value;
  final double digitWidth;

  String get formatted => value.toString().padLeft(4, '0');

  @override
  Widget build(BuildContext context) {
    final text = formatted;
    final gap = digitWidth * 0.24;
    return Semantics(
      label: 'العدّاد $text',
      value: text,
      liveRegion: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.ltr,
        children: [
          for (var i = 0; i < text.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            _DotDigit(digit: text[i], width: digitWidth),
          ],
        ],
      ),
    );
  }
}

class _DotDigit extends StatelessWidget {
  const _DotDigit({required this.digit, required this.width});

  final String digit;
  final double width;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width * _DotDigitPainter.aspectRatio),
      painter: _DotDigitPainter(digit),
    );
  }
}

class _DotDigitPainter extends CustomPainter {
  const _DotDigitPainter(this.digit);

  final String digit;

  static const gapRatio = 0.42;
  static const columns = 5;
  static const rows = 7;
  static const aspectRatio =
      (rows + (rows - 1) * gapRatio) / (columns + (columns - 1) * gapRatio);

  static const _patterns = <String, List<String>>{
    '0': [
      '01110',
      '10001',
      '10001',
      '10001',
      '10001',
      '10001',
      '01110',
    ],
    '1': [
      '00100',
      '01100',
      '00100',
      '00100',
      '00100',
      '00100',
      '01110',
    ],
    '2': [
      '01110',
      '10001',
      '00001',
      '00010',
      '00100',
      '01000',
      '11111',
    ],
    '3': [
      '01110',
      '10001',
      '00001',
      '00110',
      '00001',
      '10001',
      '01110',
    ],
    '4': [
      '00010',
      '00110',
      '01010',
      '10010',
      '11111',
      '00010',
      '00010',
    ],
    '5': [
      '11111',
      '10000',
      '11110',
      '00001',
      '00001',
      '10001',
      '01110',
    ],
    '6': [
      '00110',
      '01000',
      '10000',
      '11110',
      '10001',
      '10001',
      '01110',
    ],
    '7': [
      '11111',
      '00001',
      '00010',
      '00100',
      '01000',
      '01000',
      '01000',
    ],
    '8': [
      '01110',
      '10001',
      '10001',
      '01110',
      '10001',
      '10001',
      '01110',
    ],
    '9': [
      '01110',
      '10001',
      '10001',
      '01111',
      '00001',
      '00010',
      '01100',
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final pattern = _patterns[digit];
    if (pattern == null) {
      return;
    }

    final dot = math.min(
      size.width / (columns + (columns - 1) * gapRatio),
      size.height / (rows + (rows - 1) * gapRatio),
    );
    final gap = dot * gapRatio;
    final gridWidth = columns * dot + (columns - 1) * gap;
    final gridHeight = rows * dot + (rows - 1) * gap;
    final origin = Offset(
      (size.width - gridWidth) / 2,
      (size.height - gridHeight) / 2,
    );
    final paint = Paint()..color = AppColors.white;

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        if (pattern[row][column] != '1') {
          continue;
        }
        canvas.drawCircle(
          origin +
              Offset(
                column * (dot + gap) + dot / 2,
                row * (dot + gap) + dot / 2,
              ),
          dot / 2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotDigitPainter oldDelegate) {
    return oldDelegate.digit != digit;
  }
}
