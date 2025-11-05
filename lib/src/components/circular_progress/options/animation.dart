import 'package:flutter/animation.dart';
import 'package:creative_ui_progress/src/common.dart';

class CreativeUICircularProgressAnimation {
  /// Normal progress animation
  final Duration progressDuration;
  final Curve progressCurve;

  /// Indeterminate rotation
  final Duration indeterminateRotationDuration;

  /// Optional: override rotation with cycles per second
  final double? indeterminateSpeedCps;

  /// Motion mode: pingPong, ltr, rtl
  final IndeterminateMotion indeterminateMotion;

  /// Sweep fraction for indeterminate arc (0.0–1.0)
  final double indeterminateSweepFraction;
  // ---------------------------------------------------------------------------
  // Shimmer options (determinate mode)
  // ---------------------------------------------------------------------------

  /// Enables shimmer overlay for determinate progress.
  final bool shimmerEnabled;

  /// Duration for a full shimmer sweep across the bar.
  final Duration shimmerDuration;

  /// Width of the shimmer highlight as a fraction of the filled width.
  final double shimmerWidthFraction;

  /// Curve used for shimmer motion.
  final Curve shimmerCurve;
  final Color shimmerColor;

  final ShimmerMode shimmerMode;

  /// For ShimmerMode.count
  final int shimmerCount;

  /// Pause between cycles (used by periodic and between count cycles)
  final Duration shimmerPause;

  final double shimmerOpacity;

  const CreativeUICircularProgressAnimation({
    this.progressDuration = const Duration(milliseconds: 500),
    this.progressCurve = Curves.linear,
    this.indeterminateRotationDuration = const Duration(milliseconds: 1000),
    this.indeterminateSpeedCps,
    this.indeterminateMotion = IndeterminateMotion.ltr,
    this.indeterminateSweepFraction = 0.25,
    this.shimmerEnabled = false,
    this.shimmerDuration = const Duration(milliseconds: 1200),
    this.shimmerCurve = Curves.linear,
    this.shimmerWidthFraction = 0.35,
    this.shimmerColor = const Color(0xFFFFFFFF),
    this.shimmerMode = ShimmerMode.never,
    this.shimmerCount = 1,
    this.shimmerPause = const Duration(milliseconds: 600),
    this.shimmerOpacity = 0.7,
  });

  Duration effectiveIndeterminateDuration() {
    final cps = indeterminateSpeedCps;
    if (cps != null && cps > 0) {
      return Duration(milliseconds: (1000 / cps).round());
    }
    return indeterminateRotationDuration;
  }

  CreativeUICircularProgressAnimation copyWith({
    Duration? progressDuration,
    Curve? progressCurve,
    Duration? indeterminateRotationDuration,
    double? indeterminateSpeedCps,
    IndeterminateMotion? indeterminateMotion,
    double? indeterminateSweepFraction,
    bool? shimmerEnabled,
    Duration? shimmerDuration,
    Curve? shimmerCurve,
    double? shimmerWidthFraction,
    Color? shimmerColor,
    ShimmerMode? shimmerMode,
    int? shimmerCount,
    Duration? shimmerPause,
    double? shimmerOpacity,
  }) {
    return CreativeUICircularProgressAnimation(
      progressDuration: progressDuration ?? this.progressDuration,
      progressCurve: progressCurve ?? this.progressCurve,
      indeterminateRotationDuration:
          indeterminateRotationDuration ?? this.indeterminateRotationDuration,
      indeterminateSpeedCps:
          indeterminateSpeedCps ?? this.indeterminateSpeedCps,
      indeterminateMotion: indeterminateMotion ?? this.indeterminateMotion,
      indeterminateSweepFraction:
          indeterminateSweepFraction ?? this.indeterminateSweepFraction,
      shimmerEnabled: shimmerEnabled ?? this.shimmerEnabled,
      shimmerDuration: shimmerDuration ?? this.shimmerDuration,
      shimmerCurve: shimmerCurve ?? this.shimmerCurve,
      shimmerWidthFraction: shimmerWidthFraction ?? this.shimmerWidthFraction,
      shimmerColor: shimmerColor ?? this.shimmerColor,
      shimmerMode: shimmerMode ?? this.shimmerMode,
      shimmerCount: shimmerCount ?? this.shimmerCount,
      shimmerPause: shimmerPause ?? this.shimmerPause,
      shimmerOpacity: shimmerOpacity ?? this.shimmerOpacity,
    );
  }
}
