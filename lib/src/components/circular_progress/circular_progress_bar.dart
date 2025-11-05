import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:creative_ui_progress/src/common.dart';
import 'package:creative_ui_progress/src/components/circular_progress/options/animation.dart';
import 'package:creative_ui_progress/src/components/circular_progress/options/behaviour.dart';
import 'package:creative_ui_progress/src/components/circular_progress/options/callbacks.dart';
import 'package:creative_ui_progress/src/components/circular_progress/options/controller.dart';
import 'package:creative_ui_progress/src/components/circular_progress/options/effects.dart';
import 'package:creative_ui_progress/src/components/circular_progress/options/option.dart';
import 'package:creative_ui_progress/src/components/circular_progress/options/styles.dart';


class CreativeUICircularProgress extends StatefulWidget {
  final CreativeUICircularProgressOptions options;
  final CreativeUICircularProgressController? controller;

  const CreativeUICircularProgress({
    super.key,
    required this.options,
    this.controller,
  });

  @override
  State<CreativeUICircularProgress> createState() =>
      _CreativeUICircularProgressState();
}
class _CreativeUICircularProgressState extends State<CreativeUICircularProgress>
    with TickerProviderStateMixin {
  // Determinate
  late AnimationController _progressCtrl;
  Animation<double>? _progress;
  double _currentPct = 0.0;

  // Indeterminate
  late AnimationController _indetCtrl;
  late Animation<double> _pos;

  // Shimmer (optional)
  AnimationController? _shimmerCtrl;
  Animation<double>? _shimmerPos;
  int _shimmerPlayed = 0; // counts completed cycles for ShimmerMode.count

  // Success flash
  late AnimationController _flashCtrl;
  late Animation<double> _flashOpacity;

  // Progress decoration image
  ui.Image? _decorImage;
  ImageStream? _imgStream;
  ImageStreamListener? _imgListener;
  bool _resolvedOnce = false;

  bool _isPaused = false;
  bool _isDisposed = false;

  CreativeUICircularProgressOptions get o => widget.options;
  CreativeUICircularProgressStyles get s => o.styles;
  CreativeUICircularProgressBehavior get b => o.behavior;
  CreativeUICircularProgressAnimation get a => o.animation;
  CreativeUICircularProgressEffects get e => o.effects;
  CreativeUICircularProgressCallbacks get c => o.callbacks;

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(vsync: this, duration: a.progressDuration);
    _bindProgress(begin: 0, end: 0);

    _indetCtrl = AnimationController(
      vsync: this,
      duration: a.effectiveIndeterminateDuration(),
    );
    _bindIndeterminateCurve();

    if (a.shimmerEnabled) {
      _shimmerCtrl = AnimationController(vsync: this, duration: a.shimmerDuration)..repeat();
      _shimmerPos = CurvedAnimation(parent: _shimmerCtrl!, curve: a.shimmerCurve)
        ..addListener(() {
          if (mounted) setState(() {});
        })
  ..addStatusListener((status) async {
    if (status == AnimationStatus.completed) {
      // One cycle done
      _shimmerPlayed++;

      switch (a.shimmerMode) {
        case ShimmerMode.never:
          _shimmerCtrl?.stop();
          break;
        case ShimmerMode.once:
          _shimmerCtrl?.stop();
          break;
        case ShimmerMode.count:
          if (_shimmerPlayed >= a.shimmerCount) {
            _shimmerCtrl?.stop();
          } else {
            await Future.delayed(a.shimmerPause);
            if (mounted) _shimmerCtrl?.forward(from: 0);
          }
          break;
        case ShimmerMode.periodic:
          await Future.delayed(a.shimmerPause);
          if (mounted) _shimmerCtrl?.forward(from: 0);
          break;
        case ShimmerMode.continuous:
          _shimmerCtrl?.forward(from: 0);
          break;
      }
    }
  });
   // Start shimmer according to mode (no eager repeat)
  if (a.shimmerMode != ShimmerMode.never) {
    _shimmerPlayed = 0;
    _shimmerCtrl!.forward(from: 0);
  }
    }

    _flashCtrl = AnimationController(vsync: this, duration: e.successFlashDuration);
    _flashOpacity = CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut);

    if (widget.controller != null) {
      widget.controller!.play = _cmdPlay;
      widget.controller!.pause = _cmdPause;
      widget.controller!.resume = _cmdResume;
      widget.controller!.reverse = _cmdReverse;
    }

    _maybeStartIndeterminate();

    // ✅ If not playing immediately (and not indeterminate), show static value
    if (!b.playOnInit && !b.indeterminate) {
      _currentPct = _computeTargetPct(b.value, b.maxValue, b.loopEnabled);
    }

    if (b.playOnInit && !b.indeterminate) {
      final target = _computeTargetPct(b.value, b.maxValue, b.loopEnabled);
      _startProgress(target);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveDecorationImage();
    _resolvedOnce = true;
  }

  @override
  void didUpdateWidget(covariant CreativeUICircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Keep durations current
    _progressCtrl.duration = a.progressDuration;
    _indetCtrl.duration = a.effectiveIndeterminateDuration();
    _bindIndeterminateCurve();

    // Shimmer enable/disable + duration updates
  if (a.shimmerEnabled) {
      if (_shimmerCtrl == null) {
        _shimmerCtrl = AnimationController(vsync: this, duration: a.shimmerDuration);
        _shimmerPos = CurvedAnimation(parent: _shimmerCtrl!, curve: a.shimmerCurve)
          ..addListener(() {
            if (mounted) setState(() {});
          });
      }
      _shimmerCtrl!.duration = a.shimmerDuration;

      if (a.shimmerMode == ShimmerMode.never) {
        _shimmerCtrl!.stop();
      } else if (!_shimmerCtrl!.isAnimating) {
        _shimmerPlayed = 0;
        _shimmerCtrl!.forward(from: 0);
      }
    } else {
      _shimmerCtrl?.stop();
      _shimmerCtrl?.dispose();
      _shimmerCtrl = null;
      _shimmerPos = null;
    }

    // Re-resolve image if provider changed
    if (oldWidget.options.styles.progressDecorationImage != s.progressDecorationImage) {
      if (_resolvedOnce) {
        _resolveDecorationImage();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) => _resolveDecorationImage());
      }
    }

    // ✅ When idle (not animating), reflect latest value if playOnInit is false
    if (!_progressCtrl.isAnimating && !b.playOnInit && !b.indeterminate) {
      _currentPct = _computeTargetPct(b.value, b.maxValue, b.loopEnabled);
      if (mounted) setState(() {});
    }

    _maybeStartIndeterminate();

    // Rebind controller callbacks if controller instance changed
    if (oldWidget.controller != widget.controller && widget.controller != null) {
      widget.controller!.play = _cmdPlay;
      widget.controller!.pause = _cmdPause;
      widget.controller!.resume = _cmdResume;
      widget.controller!.reverse = _cmdReverse;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    // stop loops before disposing
    _indetCtrl.stop();
    _shimmerCtrl?.stop();

    _progress?.removeListener(_onTick);
    _progressCtrl.dispose();
    _indetCtrl.dispose();
    _shimmerCtrl?.dispose();
    _flashCtrl.dispose();

    if (_imgListener != null) {
      _imgStream?.removeListener(_imgListener!);
    }
    super.dispose();
  }

  // ---------------- IMAGE ----------------
  void _resolveDecorationImage() {
    final provider = s.progressDecorationImage;
    if (provider == null) {
      if (_imgListener != null) {
        _imgStream?.removeListener(_imgListener!);
        _imgListener = null;
        _imgStream = null;
      }
      if (_decorImage != null && mounted) {
        setState(() => _decorImage = null);
      }
      return;
    }

    final stream = provider.resolve(createLocalImageConfiguration(context));
    if (_imgStream?.key == stream.key) return;

    _imgListener ??= ImageStreamListener((info, _) {
      if (!mounted || _isDisposed) return;
      setState(() => _decorImage = info.image);
    });

    _imgStream?.removeListener(_imgListener!);
    _imgStream = stream..addListener(_imgListener!);
  }

  // -------------- ENGINES --------------
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
    if (mounted && !_isDisposed) setState(() {});
  }

  double _computeTargetPct(num value, num max, bool loop) {
    if (max == 0 || value.isNaN || value.isInfinite || max.isNaN || max.isInfinite) return 0.0;
    final pct = (value / max).toDouble();
    if (!pct.isFinite) return 0.0;
    return loop ? pct.clamp(0.0, double.infinity) : pct.clamp(0.0, 1.0);
  }

  double _safeUnit(num v) =>
      (v.isNaN || v.isInfinite) ? 0 : v.toDouble().clamp(0.0, 1.0);

  // -------------- COMMANDS --------------
  void _cmdPlay({double? percentage, double? value, double? max}) {
    if (_isDisposed) return;
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
    if (_isDisposed) return;
    _isPaused = true;
    try {
      (b.indeterminate ? _indetCtrl : _progressCtrl).stop(canceled: false);
      _shimmerCtrl?.stop(canceled: false);
    } catch (_) {}
  }

  void _cmdResume() {
    if (_isDisposed) return;
    if (_isPaused) {
      _isPaused = false;
      try {
        if (b.indeterminate) {
          final reverse = a.indeterminateMotion == IndeterminateMotion.pingPong;
          _indetCtrl.repeat(reverse: reverse);
        } else {
          _progressCtrl.forward();
        }
        _shimmerCtrl?.repeat();
      } catch (_) {}
    }
  }

  void _cmdReverse({double? toPercentage}) {
    if (_isDisposed || b.indeterminate) return;
    _startProgress(_safeUnit(toPercentage ?? 0), reverse: true);
  }

  // -------------- PROGRESS --------------
  Future<void> _startProgress(double targetPct, {bool reverse = false}) async {
    if (!mounted || _isDisposed || !targetPct.isFinite) return;

    final clamped = targetPct.clamp(0.0, 1.0);

    // No looping here for circular (your current working version),
    // if you add loops for circular, mirror your linear logic.
    await _animateTo(clamped);
    if (!mounted || _isDisposed) return;
    if (clamped >= 1.0 && e.successFlashEnabled) _flash();
  }

  Future<void> _animateTo(double endPct) async {
    if (!mounted || _isDisposed) return;
    // ✅ animate from wherever we are, not from 0
    _bindProgress(begin: _currentPct, end: endPct);
    try {
      _progressCtrl.reset();
      await _progressCtrl.forward();
    } catch (_) {
      return;
    }
    if (mounted && !_isDisposed) _currentPct = endPct;
  }

  void _maybeStartIndeterminate() {
    if (b.indeterminate) {
      _startIndeterminate();
    } else {
      try {
        _indetCtrl.stop();
      } catch (_) {}
    }
  }

  void _startIndeterminate() {
    if (_isDisposed) return;
    final reverse = a.indeterminateMotion == IndeterminateMotion.pingPong;
    try {
      _indetCtrl
        ..value = 0
        ..repeat(reverse: reverse);
    } catch (_) {}
  }

  void _flash() async {
    if (_isDisposed || !mounted) return;
    _flashCtrl
      ..value = 0
      ..forward();
    await Future.delayed(e.successFlashDuration);
    if (!_isDisposed && mounted) _flashCtrl.reverse();
  }

  // -------------- BUILD --------------
  @override
  Widget build(BuildContext context) {
    if (b.indeterminate) {
      return SizedBox(
        width: s.size,
        height: s.size,
        child: AnimatedBuilder(
          animation: _pos,
          builder: (_, __) {
            const full = 2 * math.pi;
            final sweep =
                (a.indeterminateSweepFraction.clamp(0.05, 0.95)) * full;

            double start;
            switch (a.indeterminateMotion) {
              case IndeterminateMotion.pingPong:
                start = s.startAngle + _pos.value * (full - sweep);
                break;
              case IndeterminateMotion.ltr:
                start = s.startAngle + (_pos.value * full);
                break;
              case IndeterminateMotion.rtl:
                start = s.startAngle - (_pos.value * full);
                break;
            }

            return _buildStack(
              progressSweep: sweep,
              startAngleOverride: start,
            );
          },
        ),
      );
    }

    // Determinate
    final pct = _determinePctForPaint();
    final rawSweep = pct * 2 * math.pi;

    double sweep = rawSweep;
    double start = s.startAngle;
    if (s.progressDirection == ProgressDirection.rtl) {
      sweep = -rawSweep;
      start = start + rawSweep;
    }

    return SizedBox(
      width: s.size,
      height: s.size,
      child: _buildStack(
        progressSweep: sweep,
        startAngleOverride: start,
      ),
    );
  }

  double _determinePctForPaint() {
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
    return pct.clamp(0.0, 1.0);
  }

  Widget _buildStack({
    required double progressSweep,
    required double startAngleOverride,
  }) {
    final flashLayer = e.successFlashEnabled
        ? AnimatedBuilder(
            animation: _flashOpacity,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (e.successFlashColor ?? Colors.white.withValues(alpha:0.35))
                    .withValues(alpha:_flashOpacity.value),
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
          painter: _TrackPainter(
            strokeWidth: s.strokeWidth,
            color: s.backgroundColor ?? Colors.black12,
            cap: s.strokeCap,
          ),
        ),

        // Progress arc (color or gradient)
        CustomPaint(
          size: Size(s.size, s.size),
          painter: _ArcPainter(
            strokeWidth: s.strokeWidth,
            cap: s.strokeCap,
            startAngle: startAngleOverride,
            sweep: progressSweep,
            color: s.progressColor ?? Colors.blue,
            gradient: s.progressGradient,
          ),
        ),

        // Progress decoration image (clipped to the arc)
       if (_decorImage != null && s.progressDecorationOpaque)
        CustomPaint(
          size: Size(s.size, s.size),
          painter: _ArcImagePainter(
            image: _decorImage!,
            strokeWidth: s.strokeWidth,
            cap: s.strokeCap,
            startAngle: startAngleOverride,
            sweep: progressSweep,
          ),
        )
      else ...[
        // Base arc (color/gradient)
        CustomPaint(
          size: Size(s.size, s.size),
          painter: _ArcPainter(
            strokeWidth: s.strokeWidth,
            cap: s.strokeCap,
            startAngle: startAngleOverride,
            sweep: progressSweep,
            color: s.progressColor ?? Colors.blue,
            gradient: s.progressGradient,
          ),
        ),
        // If image provided but not opaque, overlay it for a blended look
        if (_decorImage != null)
          CustomPaint(
            size: Size(s.size, s.size),
            painter: _ArcImagePainter(
              image: _decorImage!,
              strokeWidth: s.strokeWidth,
              cap: s.strokeCap,
              startAngle: startAngleOverride,
              sweep: progressSweep,
            ),
          ),
      ],

        // Shimmer overlay (optional)
        if (a.shimmerEnabled && _shimmerPos != null)
          CustomPaint(
            size: Size(s.size, s.size),
            painter: _ShimmerArcPainter(
              strokeWidth: s.strokeWidth,
              startAngle: startAngleOverride,
              sweep: progressSweep,
              t: _shimmerPos!.value,
              bandWidthFraction: a.shimmerWidthFraction,
              color: a.shimmerColor,
            ),
          ),

        if (s.center != null) s.center!,

        Positioned.fill(child: IgnorePointer(ignoring: true, child: flashLayer)),
      ],
    );
  }
}

/// ---------- Painters (same as your working versions, with arc image & shimmer) ----------

class _TrackPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final StrokeCap cap;

  _TrackPainter({
    required this.strokeWidth,
    required this.color,
    required this.cap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final r = math.min(rect.width, rect.height) / 2;
    final center = rect.center;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = cap;

    canvas.drawCircle(center, r - strokeWidth / 2, paint);
  }

  @override
  bool shouldRepaint(covariant _TrackPainter old) =>
      old.strokeWidth != strokeWidth || old.color != color || old.cap != cap;
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
    final Rect rect = Offset.zero & size;
    final r = math.min(rect.width, rect.height) / 2;
    final center = rect.center;
    final arcRect = Rect.fromCircle(center: center, radius: r - strokeWidth / 2);

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

/// Paints the progressDecoration image clipped to the **arc segment** (not the center).
class _ArcImagePainter extends CustomPainter {
  final ui.Image image;
  final double strokeWidth;
  final StrokeCap cap; // (kept for parity; clipping uses square ends)
  final double startAngle;
  final double sweep;

  _ArcImagePainter({
    required this.image,
    required this.strokeWidth,
    required this.cap,
    required this.startAngle,
    required this.sweep,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (sweep == 0) return;

    final rect = Offset.zero & size;
    final rOuter = math.min(rect.width, rect.height) / 2;      // outer radius
    final rInner = (rOuter - strokeWidth).clamp(0.0, rOuter);  // inner radius
    final center = rect.center;

    // Build annular sector (ring slice) path bounded by [rInner..rOuter], from startAngle..startAngle+sweep
    Path ringSlice(Rect outer, Rect inner, double start, double sw) {
      // Points at the arc ends
      Offset polar(double radius, double ang) =>
          Offset(center.dx + radius * math.cos(ang), center.dy + radius * math.sin(ang));

      final startOuter = polar(rOuter, start);
      // final endOuter   = polar(rOuter, start + sw);
      // final startInner = polar(rInner, start);
      final endInner   = polar(rInner, start + sw);

      final path = Path()
        ..moveTo(startOuter.dx, startOuter.dy)
        // Outer arc (sweep forward)
        ..arcTo(Rect.fromCircle(center: center, radius: rOuter), start, sw, false)
        // Connect outer end to inner end
        ..lineTo(endInner.dx, endInner.dy)
        // Inner arc (sweep back)
        ..arcTo(Rect.fromCircle(center: center, radius: rInner), start + sw, -sw, false)
        // Close back to startOuter
        ..close();

      return path;
    }

    final slice = ringSlice(
      Rect.fromCircle(center: center, radius: rOuter),
      Rect.fromCircle(center: center, radius: rInner),
      startAngle,
      sweep,
    );

    // Clip to the ring slice so only that segment shows the image
    canvas.save();
    canvas.clipPath(slice);

    // Draw the image covering the whole widget; the clip restricts it to the arc segment.
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);

    // Center-crop to square to avoid stretch
    final imgW = image.width.toDouble();
    final imgH = image.height.toDouble();
    Rect src;
    if (imgW > imgH) {
      final crop = (imgW - imgH) / 2;
      src = Rect.fromLTWH(crop, 0, imgH, imgH);
    } else {
      final crop = (imgH - imgW) / 2;
      src = Rect.fromLTWH(0, crop, imgW, imgW);
    }

    final paint = Paint()..filterQuality = FilterQuality.high;
    canvas.drawImageRect(image, src, dst, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ArcImagePainter old) =>
      old.image != image ||
      old.strokeWidth != strokeWidth ||
      old.startAngle != startAngle ||
      old.sweep != sweep;
}/// Simple shimmering band that runs along the current arc sweep.
class _ShimmerArcPainter extends CustomPainter {
  final double strokeWidth;
  final double startAngle;
  final double sweep;
  final double t; // 0..1
  final double bandWidthFraction; // relative to sweep, not strokeWidth
  final Color color;

  _ShimmerArcPainter({
    required this.strokeWidth,
    required this.startAngle,
    required this.sweep,
    required this.t,
    required this.bandWidthFraction,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (sweep == 0) return;

    final rect = Offset.zero & size;
    final r = math.min(rect.width, rect.height) / 2;
    final center = rect.center;
    final arcRect = Rect.fromCircle(center: center, radius: r - strokeWidth / 2);

    // Total angular length of the current progress sweep (always positive).
    final total = sweep.abs();
    // Direction of drawing: +1 for LTR (CCW), -1 for RTL (CW).
    final dir = sweep >= 0 ? 1.0 : -1.0;

    // Angular size of the shimmer band along the arc length (NOT stroke thickness).
    final bandAngle = (bandWidthFraction.clamp(0.05, 1.0)) * total;

    // Start the band exactly at the *beginning* of the arc when t == 0,
    // then move it forward. The band may wrap; if so, we split into two segments.
    final localStart = ((t % 1.0) * total);
    final firstLen = math.min(bandAngle, total - localStart);
    final secondLen = bandAngle - firstLen;

    void drawSegment(double localA, double len) {
      if (len <= 0) return;

      final segStart = startAngle + dir * localA;
      final signedLen = dir * len;

      // Gradient aligned to this small segment so the highlight peaks in the middle.
      final segEnd = segStart + signedLen;
      final gStart = dir > 0 ? segStart : segEnd;
      final gEnd   = dir > 0 ? segEnd   : segStart;

      final shader = SweepGradient(
        startAngle: gStart,
        endAngle: gEnd,
        colors: [
          color.withValues(alpha:0.0),
          color.withValues(alpha:0.85),
          color.withValues(alpha:0.0),
        ],
        stops: const [0.15, 0.5, 0.85],
        tileMode: TileMode.decal,
      ).createShader(arcRect);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..shader = shader
        ..strokeCap = StrokeCap.butt
        ..filterQuality = FilterQuality.high;

      canvas.drawArc(arcRect, segStart, signedLen, false, paint);
    }

    // Draw the main piece [localStart .. localStart + firstLen]
    drawSegment(localStart, firstLen);

    // If the band wrapped past the end, draw the remainder from [0 .. secondLen]
    if (secondLen > 0) {
      drawSegment(0, secondLen);
    }
  }
  @override
  bool shouldRepaint(covariant _ShimmerArcPainter old) =>
      old.strokeWidth != strokeWidth ||
      old.startAngle != startAngle ||
      old.sweep != sweep ||
      old.t != t ||
      old.bandWidthFraction != bandWidthFraction ||
      old.color != color;
}