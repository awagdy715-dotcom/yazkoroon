import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'widgets/count_ring_button.dart';
import 'widgets/dot_matrix_counter.dart';
import 'widgets/line_icons.dart';

const dhikrPhrases = <String>[
  'أستغفر الله',
  'سبحان الله',
  'الله أكبر',
  'الحمد لله',
  'لا حول ولا قوة إلا بالله',
];

class SavedDhikr {
  const SavedDhikr({required this.phrase, required this.count});

  final String phrase;
  final int count;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<int> _counts = List<int>.filled(dhikrPhrases.length, 0);
  final List<SavedDhikr> _saved = [];

  int _phraseIndex = 0;
  bool _vibration = true;
  bool _showSaved = false;
  Timer? _toastTimer;

  int get _count => _counts[_phraseIndex];
  String get _phrase => dhikrPhrases[_phraseIndex];

  void _stepPhrase(int delta) {
    setState(() {
      _phraseIndex =
          (_phraseIndex + delta + dhikrPhrases.length) % dhikrPhrases.length;
    });
  }

  void _increment() {
    setState(() => _counts[_phraseIndex]++);
    if (_vibration) {
      HapticFeedback.lightImpact();
    }
  }

  void _reset() {
    setState(() => _counts[_phraseIndex] = 0);
  }

  void _toggleVibration() {
    setState(() => _vibration = !_vibration);
    if (_vibration) {
      HapticFeedback.selectionClick();
    }
  }

  void _save() {
    setState(() {
      _saved.insert(0, SavedDhikr(phrase: _phrase, count: _count));
      if (_saved.length > 30) {
        _saved.removeLast();
      }
      _showSaved = true;
    });
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) {
        return;
      }
      setState(() => _showSaved = false);
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.navy,
        endDrawer: _SavedDrawer(entries: _saved),
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.background),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: _HomeBody(
                      scale: _scaleFor(constraints),
                      phrase: _phrase,
                      count: _count,
                      vibration: _vibration,
                      savedFlash: _showSaved,
                      onPrevious: () => _stepPhrase(-1),
                      onNext: () => _stepPhrase(1),
                      onReset: _reset,
                      onToggleVibration: _toggleVibration,
                      onSave: _save,
                      onCount: _increment,
                      onMenu: () => _scaffoldKey.currentState?.openEndDrawer(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double _scaleFor(BoxConstraints constraints) {
    return math
        .min(constraints.maxWidth / 390, constraints.maxHeight / 800)
        .clamp(0.55, 1.15);
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.scale,
    required this.phrase,
    required this.count,
    required this.vibration,
    required this.savedFlash,
    required this.onPrevious,
    required this.onNext,
    required this.onReset,
    required this.onToggleVibration,
    required this.onSave,
    required this.onCount,
    required this.onMenu,
  });

  final double scale;
  final String phrase;
  final int count;
  final bool vibration;
  final bool savedFlash;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onReset;
  final VoidCallback onToggleVibration;
  final VoidCallback onSave;
  final VoidCallback onCount;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final horizontal = 22.0 * scale;
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          child: Column(
            children: [
              SizedBox(height: 8 * scale),
              _Header(scale: scale, onMenu: onMenu),
              const Spacer(flex: 4),
              DotMatrixCounter(value: count, digitWidth: 64 * scale),
              const Spacer(flex: 5),
              _DhikrRow(
                phrase: phrase,
                scale: scale,
                onPrevious: onPrevious,
                onNext: onNext,
              ),
              SizedBox(height: 30 * scale),
              _ActionRow(
                scale: scale,
                vibration: vibration,
                savedFlash: savedFlash,
                onReset: onReset,
                onToggleVibration: onToggleVibration,
                onSave: onSave,
              ),
              const Spacer(flex: 6),
              CountRingButton(
                key: const Key('count-button'),
                diameter: 176 * scale,
                onTap: onCount,
              ),
              SizedBox(height: 16 * scale),
            ],
          ),
        ),
        Positioned(
          top: 64 * scale,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: savedFlash ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: Text(
                'تم الحفظ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                  color: AppColors.toast,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.scale, required this.onMenu});

  final double scale;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52 * scale,
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          KaabaIcon(size: 34 * scale),
          SizedBox(width: 10 * scale),
          Text(
            'يذكرون',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 26 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              height: 1,
            ),
          ),
          const Spacer(),
          _IconTap(
            key: const Key('menu-button'),
            onTap: onMenu,
            semanticLabel: 'القائمة',
            child: MenuIcon(size: 24 * scale),
          ),
        ],
      ),
    );
  }
}

class _DhikrRow extends StatelessWidget {
  const _DhikrRow({
    required this.phrase,
    required this.scale,
    required this.onPrevious,
    required this.onNext,
  });

  final String phrase;
  final double scale;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18 * scale),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          _IconTap(
            key: const Key('prev-dhikr'),
            onTap: onPrevious,
            semanticLabel: 'الذكر السابق',
            child: ChevronIcon(pointsRight: false, size: 22 * scale),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                phrase,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 28 * scale,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white,
                  height: 1.3,
                ),
              ),
            ),
          ),
          _IconTap(
            key: const Key('next-dhikr'),
            onTap: onNext,
            semanticLabel: 'الذكر التالي',
            child: ChevronIcon(pointsRight: true, size: 22 * scale),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.scale,
    required this.vibration,
    required this.savedFlash,
    required this.onReset,
    required this.onToggleVibration,
    required this.onSave,
  });

  final double scale;
  final bool vibration;
  final bool savedFlash;
  final VoidCallback onReset;
  final VoidCallback onToggleVibration;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: _LabeledAction(
            key: const Key('reset-button'),
            label: 'إعادة تعيين',
            scale: scale,
            onTap: onReset,
            icon: ResetIcon(size: 34 * scale),
          ),
        ),
        Expanded(
          child: Opacity(
            opacity: vibration ? 1 : 0.38,
            child: _LabeledAction(
              key: const Key('vibration-button'),
              label: 'اهتزاز',
              scale: scale,
              onTap: onToggleVibration,
              icon: WaveformIcon(size: 34 * scale),
            ),
          ),
        ),
        Expanded(
          child: _LabeledAction(
            key: const Key('save-button'),
            label: 'حفظ',
            scale: scale,
            onTap: onSave,
            icon: BookmarkIcon(size: 32 * scale, filled: savedFlash),
          ),
        ),
      ],
    );
  }
}

class _LabeledAction extends StatelessWidget {
  const _LabeledAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.scale,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return _IconTap(
      onTap: onTap,
      semanticLabel: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(height: 10 * scale),
          Text(
            label,
            textDirection: TextDirection.rtl,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13 * scale,
              fontWeight: FontWeight.w400,
              color: AppColors.label,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconTap extends StatelessWidget {
  const _IconTap({
    super.key,
    required this.onTap,
    required this.child,
    required this.semanticLabel,
  });

  final VoidCallback onTap;
  final Widget child;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          splashColor: const Color(0x18FFFFFF),
          highlightColor: const Color(0x10FFFFFF),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SavedDrawer extends StatelessWidget {
  const _SavedDrawer({required this.entries});

  final List<SavedDhikr> entries;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.navy,
      surfaceTintColor: Colors.transparent,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Text(
                      'يذكرون',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    KaabaIcon(size: 28),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'المحفوظات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: AppColors.label,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: entries.isEmpty
                      ? const Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            'لم تحفظ شيئًا بعد',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              color: AppColors.toast,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: entries.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: AppColors.white.withValues(alpha: 0.08),
                          ),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.phrase,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 16,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    entry.count.toString().padLeft(4, '0'),
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 15,
                                      color: AppColors.label,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
