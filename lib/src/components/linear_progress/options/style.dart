import 'package:creative_ui_progress/src/common.dart';
import 'package:flutter/material.dart';

class CreativeUIProgressBarStyles {
  final double height;
  final double width;

  final Color? progressColor;
  final Color? backgroundColor;

  final double borderRadius;
  final BoxBorder? border;
  final BoxBorder? progressBorder;

  /// Optional foreground/background overlays (gradients, glows, etc.)
  final Widget? progressDecoration;
  final Widget? backgroundDecoration;

  /// Direction of fill for determinate mode and anchoring for indeterminate.
  final ProgressDirection progressDirection;

  const CreativeUIProgressBarStyles({
    this.height = 10,
    this.width = double.infinity,
    this.progressColor,
    this.backgroundColor,
    this.borderRadius = 6,
    this.border,
    this.progressBorder,
    this.progressDecoration,
    this.backgroundDecoration,
    this.progressDirection = ProgressDirection.ltr,
  });

  CreativeUIProgressBarStyles copyWith({
    double? height,
    double? width,
    Color? progressColor,
    Color? backgroundColor,
    double? borderRadius,
    BoxBorder? border,
    BoxBorder? progressBorder,
    Widget? progressDecoration,
    Widget? backgroundDecoration,
    ProgressDirection? progressDirection,
  }) {
    return CreativeUIProgressBarStyles(
      height: height ?? this.height,
      width: width ?? this.width,
      progressColor: progressColor ?? this.progressColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      border: border ?? this.border,
      progressBorder: progressBorder ?? this.progressBorder,
      progressDecoration: progressDecoration ?? this.progressDecoration,
      backgroundDecoration: backgroundDecoration ?? this.backgroundDecoration,
      progressDirection: progressDirection ?? this.progressDirection,
    );
  }
}
