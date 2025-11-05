import 'package:creative_ui_progress/src/common.dart';
import 'package:flutter/material.dart';

class CreativeUIArcProgressAnimation {
  final Duration progressDuration;
  final Curve progressCurve;

  final Duration indeterminateRotationDuration;
  final double indeterminateSweepFraction;

  final double? indeterminateSpeedCps;
  final IndeterminateMotion indeterminateMotion;

  const CreativeUIArcProgressAnimation({
    this.progressDuration = const Duration(milliseconds: 500),
    this.progressCurve = Curves.linear,
    this.indeterminateRotationDuration = const Duration(milliseconds: 1200),
    this.indeterminateSweepFraction = 0.35,
    this.indeterminateMotion = IndeterminateMotion.ltr,
    this.indeterminateSpeedCps,
  });

  Duration effectiveIndeterminateDuration() {
    if (indeterminateSpeedCps != null && indeterminateSpeedCps! > 0) {
      final ms = (1000 / indeterminateSpeedCps!).round(); // 1 cycle
      return Duration(milliseconds: ms);
    }
    return indeterminateRotationDuration;
  }

  CreativeUIArcProgressAnimation copyWith({
    Duration? progressDuration,
    Curve? progressCurve,
    Duration? indeterminateRotationDuration,
    double? indeterminateSweepFraction,
    IndeterminateMotion? indeterminateMotion,
  }) {
    return CreativeUIArcProgressAnimation(
      progressDuration: progressDuration ?? this.progressDuration,
      progressCurve: progressCurve ?? this.progressCurve,
      indeterminateRotationDuration:
          indeterminateRotationDuration ?? this.indeterminateRotationDuration,
      indeterminateSweepFraction:
          indeterminateSweepFraction ?? this.indeterminateSweepFraction,
      indeterminateMotion: indeterminateMotion ?? this.indeterminateMotion,
    );
  }
}
