import 'package:creative_ui_progress/src/common.dart';
import 'package:creative_ui_progress/src/components/linear_progress/options/animation.dart';
import 'package:creative_ui_progress/src/components/linear_progress/options/behaviour.dart';
import 'package:creative_ui_progress/src/components/linear_progress/options/callbacks.dart';
import 'package:creative_ui_progress/src/components/linear_progress/options/controller.dart';
import 'package:creative_ui_progress/src/components/linear_progress/options/effects.dart';
import 'package:creative_ui_progress/src/components/linear_progress/options/options.dart';
import 'package:creative_ui_progress/src/components/linear_progress/options/style.dart';
import 'package:flutter/material.dart';

class CreativeUIProgressBar extends StatefulWidget {
  final CreativeUIProgressBarOptions options;
  final CreativeUIProgressBarController? controller;

  const CreativeUIProgressBar({
    super.key,
    required this.options,
    this.controller,
  });

  @override
  State<CreativeUIProgressBar> createState() => _CreativeUIProgressBarState();
}

class _CreativeUIProgressBarState extends State<CreativeUIProgressBar>
    with TickerProviderStateMixin {
  // Determinate
  late AnimationController _progressCtrl;
  Animation<double>? _progress;
  double _currentPct = 0.0;

  // Indeterminate
  late AnimationController _indetCtrl;
  late Animation<double> _pos; // 0..1
  bool _isPaused = false;

  // Effects (flash)
  late AnimationController _flashCtrl;
  late Animation<double> _flashOpacity;

  // Shimmer (determinate overlay)
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerPos;

  CreativeUIProgressBarOptions get o => widget.options;
  CreativeUIProgressBarStyles get s => o.styles;
  CreativeUIProgressBarBehavior get b => o.behavior;
  CreativeUIProgressBarAnimation get a => o.animation;
  CreativeUIProgressBarCallbacks get c => o.callbacks;
  CreativeUIProgressEffects get e => o.effects;

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
      duration: a.effectiveIndeterminateDuration(),
    );
    _bindIndeterminateCurve();

    _flashCtrl = AnimationController(
      vsync: this,
      duration: e.successFlashDuration,
    );
    _flashOpacity = CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut);

    // Shimmer setup
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: a.shimmerDuration,
    );
    _shimmerPos = CurvedAnimation(parent: _shimmerCtrl, curve: a.shimmerCurve);

    if (widget.controller != null) {
      widget.controller!.play = _cmdPlay;
      widget.controller!.pause = _cmdPause;
      widget.controller!.resume = _cmdResume;
      widget.controller!.reverse = _cmdReverse;
    }

    _maybeStartIndeterminate();
    _maybeStartOrStopShimmer();

    if (b.playOnInit && !b.indeterminate) {
      final target = _computeTargetPct(b.value, b.maxValue, b.loopEnabled);
      _startProgress(target);
    }
  }

  @override
  void didUpdateWidget(covariant CreativeUIProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller &&
        widget.controller != null) {
      widget.controller!.play = _cmdPlay;
      widget.controller!.pause = _cmdPause;
      widget.controller!.resume = _cmdResume;
      widget.controller!.reverse = _cmdReverse;
    }

    _progressCtrl.duration = a.progressDuration;
    _indetCtrl.duration = a.effectiveIndeterminateDuration();
    _bindIndeterminateCurve();

    // Shimmer sync
    _shimmerCtrl.duration = a.shimmerDuration;
    _shimmerPos = CurvedAnimation(parent: _shimmerCtrl, curve: a.shimmerCurve);
    _maybeStartOrStopShimmer();

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
    _shimmerCtrl.dispose();
    super.dispose();
  }

  // ---------------- Engines

  void _bindProgress({required double begin, required double end}) {
    _progress?.removeListener(_onTick);
    _progress = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _progressCtrl, curve: a.progressCurve),
    )..addListener(_onTick);
  }

  void _bindIndeterminateCurve() {
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
      _maybeFlash();
      c.onFinalCompleted?.call(clamped >= 1.0);
      return;
    }

    final fullLoops = targetPct.floor();
    final remainder = targetPct - fullLoops;

    for (var i = 0; i < fullLoops; i++) {
      await _animateTo(1.0);
      _maybeFlash();
      c.onCompletedInterval?.call();
      _currentPct = 0.0;
    }

    if (remainder > 0) {
      await _animateTo(remainder);
      _maybeFlash();
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
      final reverse = a.indeterminateMotion == IndeterminateMotion.pingPong;
      _indetCtrl
        ..value = 0
        ..repeat(reverse: reverse);
    } else {
      _indetCtrl.stop();
    }
  }

  void _maybeStartOrStopShimmer() {
    final shouldShimmer = a.shimmerEnabled && !b.indeterminate;
    if (shouldShimmer && !_shimmerCtrl.isAnimating) {
      _shimmerCtrl
        ..value = 0
        ..repeat();
    } else if (!shouldShimmer && _shimmerCtrl.isAnimating) {
      _shimmerCtrl.stop();
    }
  }

  void _cmdPlay({double? percentage, double? value, double? max}) {
    if (b.indeterminate) {
      _maybeStartIndeterminate();
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
    if (_shimmerCtrl.isAnimating) _shimmerCtrl.stop(canceled: false);
  }

  void _cmdResume() {
    if (_isPaused) {
      _isPaused = false;
      if (b.indeterminate) {
        _maybeStartIndeterminate();
      } else {
        _progressCtrl.forward();
      }
      _maybeStartOrStopShimmer();
    }
  }

  void _cmdReverse({double? toPercentage}) {
    if (b.indeterminate) return;
    _startProgress(_safeUnit(toPercentage ?? 0), reverse: true);
  }

  void _maybeFlash() {
    if (!e.successFlashEnabled) return;
    _flashCtrl
      ..value = 0
      ..forward();
    Future.delayed(e.successFlashDuration, () {
      if (mounted) _flashCtrl.reverse();
    });
  }

  // ---------------- Build

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(s.borderRadius),
      child: SizedBox(
        height: s.height,
        width: s.width,
        child: Stack(
          children: [
            // Background
            Positioned.fill(child: _buildBackground()),

            // Foreground (determinate or indeterminate)
            b.indeterminate ? _buildIndeterminate() : _buildDeterminate(),

            // Optional outer border overlay
            if (s.border != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(decoration: BoxDecoration(border: s.border)),
                ),
              ),

            // Flash overlay
            if (e.successFlashEnabled)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _flashOpacity,
                  builder: (_, __) => IgnorePointer(
                    ignoring: true,
                    child: Container(
                      color:
                          (e.successFlashColor ??
                                  Colors.white.withValues(alpha: 0.3))
                              .withValues(alpha: _flashOpacity.value),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(color: s.backgroundColor ?? Colors.black12),
        if (s.backgroundDecoration != null) s.backgroundDecoration!,
      ],
    );
  }

  Widget _buildForeground() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(s.borderRadius),
      child: Stack(
        children: [
          // Base fill color or border
          Container(
            decoration: BoxDecoration(
              color: s.progressColor ?? Colors.blue,
              border: s.progressBorder,
            ),
          ),

          // Decoration (e.g. image, gradient, glow) stretched to fit
          if (s.progressDecoration != null)
            Positioned.fill(
              child: IgnorePointer(
                child: FittedBox(
                  fit: BoxFit
                      .cover, // or BoxFit.fill if you prefer no aspect ratio
                  alignment: Alignment.center,
                  child: s.progressDecoration!,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Foreground + optional shimmer overlay (determinate mode).
  Widget _buildForegroundWithOptionalShimmer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Stack(
          children: [
            _buildForeground(),
            if (a.shimmerEnabled && !b.indeterminate)
              AnimatedBuilder(
                animation: _shimmerPos,
                builder: (_, __) {
                  // Shimmer “highlight” width
                  final w = (width * a.shimmerWidthFraction).clamp(4.0, width);
                  final t = _shimmerPos.value; // 0..1
                  final isRtl = s.progressDirection == ProgressDirection.rtl;

                  // Slide across filled region respecting direction
                  final left = isRtl ? null : (t * (width + w)) - w;
                  final right = isRtl ? (t * (width + w)) - w : null;

                  return Positioned(
                    left: left,
                    right: right,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        width: w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              a.shimmerColor.withValues(alpha: 0.0),
                              a.shimmerColor.withValues(alpha: 0.6),
                              a.shimmerColor.withValues(alpha: 0.0),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildDeterminate() {
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

    final anchor = (s.progressDirection == ProgressDirection.ltr)
        ? Alignment.centerLeft
        : Alignment.centerRight;

    return Align(
      alignment: anchor,
      child: FractionallySizedBox(
        widthFactor: pct.clamp(0.0, 1.0),
        alignment: anchor,
        child: _buildForegroundWithOptionalShimmer(),
      ),
    );
  }

  Widget _buildIndeterminate() {
    // For LTR/RTL: head moves across and keeps going until tail fully disappears.
    // For pingPong: _pos already bounces due to reverse:true.
    return AnimatedBuilder(
      animation: _pos,
      builder: (_, __) {
        final head = a.indeterminateHeadFraction.clamp(0.05, 0.6);
        final total = 1.0 + head; // ensures tail clears before restart

        double t = _pos.value; // 0..1
        switch (a.indeterminateMotion) {
          case IndeterminateMotion.pingPong:
            // Move window between [0..(1-head)], symmetric bounce
            final startFrac = (t * (1.0 - head)).clamp(0.0, 1.0 - head);
            final endFrac = startFrac + head;
            return _positionedSegment(startFrac, endFrac);
          case IndeterminateMotion.ltr:
            // constant forward
            break;
          case IndeterminateMotion.rtl:
            t = 1.0 - t; // mirror
            break;
        }

        final offset = t * total; // 0..(1+head)
        final clamped = offset.clamp(0.0, 1.0);
        final visible = (1.0 - offset).clamp(0.0, head);

        final startFrac = clamped;
        final endFrac = clamped + visible;

        return _positionedSegment(startFrac, endFrac);
      },
    );
  }

  /// Places the moving segment by fractional [start,end] of total width,
  /// respecting LTR/RTL bar direction.
  Widget _positionedSegment(double startFrac, double endFrac) {
    startFrac = startFrac.clamp(0.0, 1.0);
    endFrac = endFrac.clamp(startFrac, 1.0);

    final startPx = startFrac * s.width;
    final endPx = endFrac * s.width;
    final segWidth = (endPx - startPx).clamp(0.0, s.width);

    if (s.progressDirection == ProgressDirection.ltr) {
      return Stack(
        children: [
          Positioned(
            left: startPx,
            width: segWidth,
            top: 0,
            bottom: 0,
            child: _buildForeground(),
          ),
        ],
      );
    } else {
      return Stack(
        children: [
          Positioned(
            right: startPx,
            width: segWidth,
            top: 0,
            bottom: 0,
            child: _buildForeground(),
          ),
        ],
      );
    }
  }
}
