import 'dart:math' as math;

import 'package:creative_ui_progress/src/common.dart';
import 'package:creative_ui_progress/src/components/arc_progress/options/animation.dart';
import 'package:creative_ui_progress/src/components/arc_progress/options/behaviour.dart';
import 'package:creative_ui_progress/src/components/arc_progress/options/callbacks.dart';
import 'package:creative_ui_progress/src/components/arc_progress/options/controller.dart';
import 'package:creative_ui_progress/src/components/arc_progress/options/effects.dart';
import 'package:creative_ui_progress/src/components/arc_progress/options/option.dart';
import 'package:creative_ui_progress/src/components/arc_progress/options/styles.dart';
import 'package:flutter/material.dart';

class CreativeUIArcProgress extends StatefulWidget {
  final CreativeUIArcProgressController? controller;
  final CreativeUIArcProgressOptions options;

  const CreativeUIArcProgress({
    super.key,
    required this.options,
    this.controller,
  });

  @override
  State<CreativeUIArcProgress> createState() => _CreativeUIArcProgressState();
}

class _CreativeUIArcProgressState extends State<CreativeUIArcProgress>
    with TickerProviderStateMixin {
  // Determinate progress tween
  late AnimationController _progressCtrl;
  Animation<double>? _progress;

  // Indeterminate position driver (0..1)
  late AnimationController _indetCtrl;
  late Animation<double> _pos;

  // Success flash
  late AnimationController _flashCtrl;
  late Animation<double> _flashOpacity;

  double _currentPct = 0.0;
  bool _isPaused = false;

  CreativeUIArcProgressOptions get o => widget.options;
  CreativeUIArcProgressStyles get s => o.styles;
  CreativeUIArcProgressBehavior get b => o.behavior;
  CreativeUIArcProgressAnimation get a => o.animation;
  CreativeUIArcProgressEffects get e => o.effects;
  CreativeUIArcProgressCallbacks get c => o.callbacks;

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: a.progressDuration,
    );
    _bindProgress(begin: 0, end: 0);

    _indetCtrl = AnimationController(
      vsync: this,
      duration: a.indeterminateRotationDuration,
    );
    _bindIndeterminateCurve();

    _flashCtrl = AnimationController(
      vsync: this,
      duration: e.successFlashDuration,
    );
    _flashOpacity = CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut);

    // Wire controller commands
    if (widget.controller != null) {
      widget.controller!.play = _cmdPlay;
      widget.controller!.pause = _cmdPause;
      widget.controller!.resume = _cmdResume;
      widget.controller!.reverse = _cmdReverse;
    }

    _maybeStartIndeterminate();

    if (b.playOnInit && !b.indeterminate) {
      final target = _computeTargetPct(b.value, b.maxValue, b.loopEnabled);
      _startProgress(target);
    }
  }

  @override
  void didUpdateWidget(covariant CreativeUIArcProgress oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller &&
        widget.controller != null) {
      widget.controller!.play = _cmdPlay;
      widget.controller!.pause = _cmdPause;
      widget.controller!.resume = _cmdResume;
      widget.controller!.reverse = _cmdReverse;
    }

    _progressCtrl.duration = a.progressDuration;

    // Respect speed/duration & curve for the current motion
    _indetCtrl.duration = a.effectiveIndeterminateDuration();
    _bindIndeterminateCurve();

    if (!_progressCtrl.isAnimating && !b.playOnInit && !b.indeterminate) {
      _currentPct = _computeTargetPct(b.value, b.maxValue, b.loopEnabled);
      setState(() {});
    }

    _maybeStartIndeterminate();
  }

  @override
  void dispose() {
    _progress?.removeListener(_onTick);
    _progressCtrl.dispose();
    _indetCtrl.dispose();
    _flashCtrl.dispose();
    super.dispose();
  }

  // ---------- Controller commands

  void _cmdPlay({double? percentage, double? value, double? max}) {
    if (b.indeterminate) {
      _startIndeterminate();
      return;
    }
    final target = (percentage != null)
        ? _safeUnit(percentage)
        : _computeTargetPct(value ?? b.value, max ?? b.maxValue, b.loopEnabled);
    _startProgress(target);
  }

  void _cmdPause() {
    _isPaused = true;
    (b.indeterminate ? _indetCtrl : _progressCtrl).stop(canceled: false);
  }

  void _cmdResume() {
    if (_isPaused) {
      _isPaused = false;
      if (b.indeterminate) {
        _startIndeterminate();
      } else {
        _progressCtrl.forward();
      }
    }
  }

  void _cmdReverse({double? toPercentage}) {
    if (b.indeterminate) return;
    _startProgress(_safeUnit(toPercentage ?? 0), reverse: true);
  }

  // ---------- Engines

  void _bindProgress({required double begin, required double end}) {
    _progress?.removeListener(_onTick);
    _progress = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _progressCtrl, curve: a.progressCurve),
    )..addListener(_onTick);
  }

  void _bindIndeterminateCurve() {
    // pingPong eases; ltr/rtl are linear constant-speed
    final curve = (a.indeterminateMotion == IndeterminateMotion.pingPong)
        ? Curves.easeInOut
        : Curves.linear;
    _pos = CurvedAnimation(parent: _indetCtrl, curve: curve);
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  double _computeTargetPct(num value, num max, bool loop) {
    if (max == 0 ||
        value.isNaN ||
        value.isInfinite ||
        max.isNaN ||
        max.isInfinite) {
      return 0.0;
    }
    final pct = (value / max).toDouble();
    if (!pct.isFinite) return 0.0;
    return loop ? pct.clamp(0.0, double.infinity) : pct.clamp(0.0, 1.0);
  }

  double _safeUnit(num v) => (v.isNaN || v.isInfinite)
      ? 0.0
      : v.toDouble().clamp(0.0, double.infinity);

  Future<void> _startProgress(double targetPct, {bool reverse = false}) async {
    if (!mounted || !targetPct.isFinite) return;

    if (reverse) {
      final clamped = targetPct.clamp(0.0, 1.0);
      await _animateTo(clamped);
      c.onFinalCompleted?.call(false);
      return;
    }

    if (!b.loopEnabled) {
      final clamped = targetPct.clamp(0.0, 1.0);
      await _animateTo(clamped);
      if (clamped >= 1.0 && e.successFlashEnabled) _flash();
      c.onFinalCompleted?.call(clamped >= 1.0);
      return;
    }

    final fullLoops = targetPct.floor();
    final remainder = targetPct - fullLoops;

    for (var i = 0; i < fullLoops; i++) {
      await _animateTo(1.0);
      if (e.successFlashEnabled) _flash();
      c.onCompletedInterval?.call();
      _currentPct = 0.0;
    }

    if (remainder > 0) {
      await _animateTo(remainder);
      c.onCompletedInterval?.call();
      _currentPct = remainder;
    }

    c.onFinalCompleted?.call(fullLoops > 0);
  }

  Future<void> _animateTo(double endPct) async {
    _bindProgress(begin: _currentPct, end: endPct);
    _progressCtrl.reset();
    await _progressCtrl.forward();
    _currentPct = endPct;
  }

  void _maybeStartIndeterminate() {
    if (b.indeterminate) {
      _startIndeterminate();
    } else {
      _indetCtrl.stop();
    }
  }

  void _startIndeterminate() {
    final reverse = a.indeterminateMotion == IndeterminateMotion.pingPong;
    _indetCtrl
      ..value = 0
      ..repeat(reverse: reverse);
  }

  void _flash() async {
    _flashCtrl
      ..value = 0
      ..forward();
    await Future.delayed(e.successFlashDuration);
    if (mounted) _flashCtrl.reverse();
  }

  // ---------- Build

  @override
  Widget build(BuildContext context) {
    if (b.indeterminate) {
      return SizedBox(
        width: s.size,
        height: s.size,
        child: AnimatedBuilder(
          animation: _pos,
          builder: (_, __) {
            final track = s.arcSweep; // total radians available
            final baseSweep =
                (a.indeterminateSweepFraction.clamp(0.05, 0.95)) * track;

            switch (a.indeterminateMotion) {
              case IndeterminateMotion.pingPong:
                // Bounce within the visible window only
                final window = (track - baseSweep).clamp(0.0, track);
                final start = s.startAngle + _pos.value * window;
                return _stack(progressSweep: baseSweep, startAngle: start);

              case IndeterminateMotion.ltr:
              case IndeterminateMotion.rtl:
                // Smoother LTR/RTL:
                // Travel across the whole track PLUS an extra 'baseSweep' distance
                // so the tail fully disappears before we restart.
                final totalTravel = track + baseSweep; // radians
                final offset = _pos.value * totalTravel;

                // Clamp start within [0, track]; beyond that we keep it at the edge while
                // the visible sweep shrinks to 0 (tail clears out).
                final clamped = offset.clamp(0.0, track);

                // Visible sweep shrinks near the end so we don't hard-cut at the boundary.
                // Example: near the right edge (LTR), track - offset gets small -> arc shortens to 0.
                final visibleSweep = math.max(
                  0.0,
                  math.min(baseSweep, track - offset),
                );

                double start;
                if (a.indeterminateMotion == IndeterminateMotion.ltr) {
                  // Move start from left->right
                  start = s.startAngle + clamped;
                } else {
                  // Move start from right->left
                  start = s.startAngle + (track - clamped);
                }

                return _stack(progressSweep: visibleSweep, startAngle: start);
            }
          },
        ),
      );
    }

    // ---- Determinate ----
    double pct;
    if (_progressCtrl.isAnimating) {
      pct = _progress?.value ?? _currentPct;
    } else if (b.playOnInit && (_progress != null)) {
      pct = _progress!.value;
    } else {
      pct = _computeTargetPct(b.value, b.maxValue, b.loopEnabled);
      _currentPct = b.loopEnabled ? _currentPct : pct;
    }

    if (b.useDiscreteSteps && b.steps > 1) {
      final step = 1 / b.steps;
      pct = (pct / step).floor() * step;
      pct = pct.clamp(0.0, 1.0);
    }

    final rawSweep = (pct.clamp(0.0, 1.0)) * s.arcSweep;

    // Apply determinate direction
    double sweep = rawSweep;
    double start = s.startAngle;
    if (s.progressDirection == ProgressDirection.rtl) {
      sweep = -rawSweep;
      start = start + rawSweep;
    }

    return SizedBox(
      width: s.size,
      height: s.size,
      child: _stack(progressSweep: sweep, startAngle: start),
    );
  }

  Widget _stack({required double progressSweep, required double startAngle}) {
    final flash = e.successFlashEnabled
        ? AnimatedBuilder(
            animation: _flashOpacity,
            builder: (_, __) => CustomPaint(
              size: Size(s.size, s.size),
              painter: _ArcFlashPainter(
                strokeWidth: s.strokeWidth,
                startAngle: startAngle,
                sweep: progressSweep,
                color: (e.successFlashColor ?? Colors.white.withValues(alpha:0.35))
                    .withValues(alpha:_flashOpacity.value),
                cap: s.strokeCap,
              ),
            ),
          )
        : const SizedBox.shrink();

    return Stack(
      alignment: Alignment.center,
      children: [
        // Track
        CustomPaint(
          size: Size(s.size, s.size),
          painter: _ArcTrackPainter(
            strokeWidth: s.strokeWidth,
            color: s.trackColor ?? Colors.black12,
            startAngle: s.startAngle,
            sweep: s.arcSweep,
            cap: s.strokeCap,
          ),
        ),
        // Progress arc
        CustomPaint(
          size: Size(s.size, s.size),
          painter: _ArcPainter(
            strokeWidth: s.strokeWidth,
            cap: s.strokeCap,
            startAngle: startAngle,
            sweep: progressSweep,
            color: s.progressColor ?? Colors.blue,
            gradient: s.progressGradient,
          ),
        ),
        if (s.center != null) s.center!,
        // Flash overlay (only over the progress arc)
        Positioned.fill(child: IgnorePointer(ignoring: true, child: flash)),
      ],
    );
  }
}

/// -------------------------------
/// Painters
/// -------------------------------
class _ArcTrackPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double startAngle;
  final double sweep;
  final StrokeCap cap;

  _ArcTrackPainter({
    required this.strokeWidth,
    required this.color,
    required this.startAngle,
    required this.sweep,
    required this.cap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = math.min(rect.width, rect.height) / 2;
    final center = rect.center;
    final arcRect = Rect.fromCircle(
      center: center,
      radius: r - strokeWidth / 2,
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = cap;

    canvas.drawArc(arcRect, startAngle, sweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcTrackPainter old) =>
      old.strokeWidth != strokeWidth ||
      old.color != color ||
      old.startAngle != startAngle ||
      old.sweep != sweep ||
      old.cap != cap;
}

class _ArcPainter extends CustomPainter {
  final double strokeWidth;
  final StrokeCap cap;
  final double startAngle;
  final double sweep;
  final Color color;
  final SweepGradient? gradient;

  _ArcPainter({
    required this.strokeWidth,
    required this.cap,
    required this.startAngle,
    required this.sweep,
    required this.color,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = math.min(rect.width, rect.height) / 2;
    final center = rect.center;
    final arcRect = Rect.fromCircle(
      center: center,
      radius: r - strokeWidth / 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = cap;

    if (gradient != null) {
      paint.shader = gradient!.createShader(arcRect);
    } else {
      paint.color = color;
    }

    canvas.drawArc(arcRect, startAngle, sweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.strokeWidth != strokeWidth ||
      old.cap != cap ||
      old.startAngle != startAngle ||
      old.sweep != sweep ||
      old.color != color ||
      old.gradient != gradient;
}

/// Flash painter draws a translucent stroke over the progress arc only.
class _ArcFlashPainter extends CustomPainter {
  final double strokeWidth;
  final double startAngle;
  final double sweep;
  final Color color;
  final StrokeCap cap;

  _ArcFlashPainter({
    required this.strokeWidth,
    required this.startAngle,
    required this.sweep,
    required this.color,
    required this.cap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (sweep <= 0) return;
    final rect = Offset.zero & size;
    final r = math.min(rect.width, rect.height) / 2;
    final center = rect.center;
    final arcRect = Rect.fromCircle(
      center: center,
      radius: r - strokeWidth / 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = cap
      ..color = color;

    canvas.drawArc(arcRect, startAngle, sweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcFlashPainter old) =>
      old.strokeWidth != strokeWidth ||
      old.startAngle != startAngle ||
      old.sweep != sweep ||
      old.color != color ||
      old.cap != cap;
}
