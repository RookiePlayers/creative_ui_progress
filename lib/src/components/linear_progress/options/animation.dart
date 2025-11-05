import 'package:creative_ui_progress/creative_ui_progress.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

/// Defines all animation-related configuration for [CreativeUIProgressBar].
///
/// This class controls how determinate and indeterminate animations behave:
/// - [progressDuration] / [progressCurve]: how the bar animates toward a new value
/// - [indeterminateDuration] / [indeterminateSpeedCps]: base speed or cycles per second
/// - [indeterminateMotion]: motion type (pingPong / ltr / rtl)
/// - [indeterminateHeadFraction]: size of moving head (indeterminate)
/// - [shimmerEnabled], [shimmerDuration], [shimmerWidthFraction], [shimmerCurve]: optional shimmer overlay
class CreativeUIProgressBarAnimation {
  /// Duration of determinate tween (e.g., from 0% → 100%).
  final Duration progressDuration;

  /// Easing curve for determinate tween.
  final Curve progressCurve;

  /// Duration of one full indeterminate cycle (ignored if [indeterminateSpeedCps] is set).
  final Duration indeterminateDuration;

  /// Optional: cycles per second for indeterminate motion.
  /// If > 0, overrides [indeterminateDuration].
  final double? indeterminateSpeedCps;

  /// Motion mode: left-to-right, right-to-left, or ping-pong.
  final IndeterminateMotion indeterminateMotion;

  /// Size of the moving head (0.05–0.6 recommended).
  final double indeterminateHeadFraction;

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

  const CreativeUIProgressBarAnimation({
    this.progressDuration = const Duration(milliseconds: 500),
    this.progressCurve = Curves.linear,
    this.indeterminateDuration = const Duration(milliseconds: 1000),
    this.indeterminateSpeedCps,
    this.indeterminateMotion = IndeterminateMotion.ltr,
    this.indeterminateHeadFraction = 0.25,
    this.shimmerEnabled = false,
    this.shimmerMode = ShimmerMode.never,
    this.shimmerCount = 1,
    this.shimmerPause = const Duration(milliseconds: 600),
    this.shimmerDuration = const Duration(milliseconds: 1200),
    this.shimmerCurve = Curves.linear,
    this.shimmerWidthFraction = 0.35,
    this.shimmerColor = const Color(0xFFFFFFFF),
    this.shimmerOpacity = 0.7,

  });

  /// Calculates effective duration for indeterminate motion based on [indeterminateSpeedCps].
  Duration effectiveIndeterminateDuration() {
    final cps = indeterminateSpeedCps;
    if (cps != null && cps > 0) {
      final ms = (1000 / cps).round();
      return Duration(milliseconds: ms);
    }
    return indeterminateDuration;
  }

  /// Creates a modified copy with selected fields changed.
  CreativeUIProgressBarAnimation copyWith({
    Duration? progressDuration,
    Curve? progressCurve,
    Duration? indeterminateDuration,
    double? indeterminateSpeedCps,
    IndeterminateMotion? indeterminateMotion,
    double? indeterminateHeadFraction,
    bool? shimmerEnabled,
    Duration? shimmerDuration,
    double? shimmerWidthFraction,
    Curve? shimmerCurve,
    Color? shimmerColor,
    ShimmerMode? shimmerMode,
    int? shimmerCount,
    Duration? shimmerPause,
    double? shimmerOpacity,
  }) {
    return CreativeUIProgressBarAnimation(
      progressDuration: progressDuration ?? this.progressDuration,
      progressCurve: progressCurve ?? this.progressCurve,
      indeterminateDuration: indeterminateDuration ?? this.indeterminateDuration,
      indeterminateSpeedCps: indeterminateSpeedCps ?? this.indeterminateSpeedCps,
      indeterminateMotion: indeterminateMotion ?? this.indeterminateMotion,
      indeterminateHeadFraction: indeterminateHeadFraction ?? this.indeterminateHeadFraction,
      shimmerEnabled: shimmerEnabled ?? this.shimmerEnabled,
      shimmerDuration: shimmerDuration ?? this.shimmerDuration,
      shimmerWidthFraction: shimmerWidthFraction ?? this.shimmerWidthFraction,
      shimmerCurve: shimmerCurve ?? this.shimmerCurve,
      shimmerColor: shimmerColor ?? this.shimmerColor,
      shimmerMode: shimmerMode ?? this.shimmerMode,
      shimmerCount: shimmerCount ?? this.shimmerCount,
      shimmerPause: shimmerPause ?? this.shimmerPause,
      shimmerOpacity: shimmerOpacity ?? this.shimmerOpacity,
    );
  }
}