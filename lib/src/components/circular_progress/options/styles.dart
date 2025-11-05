import 'package:flutter/material.dart';
import 'package:creative_ui_progress/src/common.dart';

class CreativeUICircularProgressStyles {
  /// Size of the circle (width & height).
  final double size;

  /// Stroke width of the ring.
  final double strokeWidth;

  /// Starting angle in radians (default top = -π/2).
  final double startAngle;

  /// Direction of progress (LTR = clockwise).
  final ProgressDirection progressDirection;

  /// If true, the decoration fully replaces the base arc (no color/gradient behind it).
  /// If false, the base arc is drawn first and the decoration is layered on top.
  final bool progressDecorationOpaque;

  /// Preferred: an ImageProvider painted in the exact arc bounds (no layout drift).
  final ImageProvider? progressDecorationImage;
  final BoxFit progressDecorationFit; // how to fit image inside arc bounds
  final Alignment progressDecorationAlignment;

  /// Stroke cap shape.
  final StrokeCap strokeCap;

  /// Background ring color.
  final Color? backgroundColor;

  /// Progress ring color.
  final Color? progressColor;

  /// Gradient for the progress arc (overrides color if set).
  final SweepGradient? progressGradient;

  /// Optional widget drawn in the center of the ring.
  final Widget? center;

  /// NEW: Widget drawn along the progress arc, clipped to the segment.
  final Widget? progressDecoration;

  const CreativeUICircularProgressStyles({
    this.size = 64,
    this.strokeWidth = 6,
    this.startAngle = -1.5708, // top center
    this.progressDirection = ProgressDirection.ltr,
    this.strokeCap = StrokeCap.round,
    this.backgroundColor,
    this.progressColor,
    this.progressGradient,
    this.center,
    this.progressDecoration,
    this.progressDecorationOpaque = false,
    this.progressDecorationImage,
    this.progressDecorationFit = BoxFit.cover,
    this.progressDecorationAlignment = Alignment.center,
  });

  CreativeUICircularProgressStyles copyWith({
    double? size,
    double? strokeWidth,
    double? startAngle,
    ProgressDirection? progressDirection,
    StrokeCap? strokeCap,
    Color? backgroundColor,
    Color? progressColor,
    SweepGradient? progressGradient,
    Widget? center,
    Widget? progressDecoration,
    bool? progressDecorationOpaque,
    ImageProvider? progressDecorationImage,
    BoxFit? progressDecorationFit,
    Alignment? progressDecorationAlignment,
  }) {
    return CreativeUICircularProgressStyles(
      size: size ?? this.size,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      startAngle: startAngle ?? this.startAngle,
      progressDirection: progressDirection ?? this.progressDirection,
      strokeCap: strokeCap ?? this.strokeCap,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      progressColor: progressColor ?? this.progressColor,
      progressGradient: progressGradient ?? this.progressGradient,
      center: center ?? this.center,
      progressDecoration: progressDecoration ?? this.progressDecoration,
      progressDecorationOpaque:
          progressDecorationOpaque ?? this.progressDecorationOpaque,
      progressDecorationImage: progressDecorationImage ?? this.progressDecorationImage,
      progressDecorationFit: progressDecorationFit ?? this.progressDecorationFit,
      progressDecorationAlignment: progressDecorationAlignment ?? this.progressDecorationAlignment,
    );
  }
}