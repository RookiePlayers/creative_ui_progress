import 'dart:math' as math;
import 'package:creative_ui_progress/src/common.dart';
import 'package:flutter/material.dart';

class CreativeUIArcProgressStyles {
  /// Canvas size (width=height=size)
  final double size;

  /// Arc stroke
  final double strokeWidth;
  final StrokeCap strokeCap;

  /// Arc geometry
  /// - [startAngle] in radians (0 = along +X axis, -π/2 = up)
  /// - [arcSweep] total radians spanned by the progress track
  final double startAngle;
  final double arcSweep;

  /// Colors / gradient
  final Color? progressColor;
  final Color? trackColor;
  final SweepGradient? progressGradient;

  /// Optional center widget
  final Widget? center;

  /// Direction of progress fill
  final ProgressDirection progressDirection;

  const CreativeUIArcProgressStyles({
    this.size = 72,
    this.strokeWidth = 8,
    this.strokeCap = StrokeCap.round,
    this.startAngle = -math.pi / 2, // top
    this.arcSweep = math.pi * 1.25, // ~225°
    this.progressColor,
    this.trackColor,
    this.progressGradient,
    this.center,
    this.progressDirection = ProgressDirection.ltr,
  });

  CreativeUIArcProgressStyles copyWith({
    double? size,
    double? strokeWidth,
    StrokeCap? strokeCap,
    double? startAngle,
    double? arcSweep,
    Color? progressColor,
    Color? trackColor,
    SweepGradient? progressGradient,
    Widget? center,
  }) {
    return CreativeUIArcProgressStyles(
      size: size ?? this.size,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeCap: strokeCap ?? this.strokeCap,
      startAngle: startAngle ?? this.startAngle,
      arcSweep: arcSweep ?? this.arcSweep,
      progressColor: progressColor ?? this.progressColor,
      trackColor: trackColor ?? this.trackColor,
      progressGradient: progressGradient ?? this.progressGradient,
      center: center ?? this.center,
    );
  }
}