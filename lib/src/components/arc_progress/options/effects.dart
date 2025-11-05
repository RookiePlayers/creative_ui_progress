import 'package:flutter/material.dart';

class CreativeUIArcProgressEffects {
  final bool successFlashEnabled;
  final Color? successFlashColor;
  final Duration successFlashDuration;

  const CreativeUIArcProgressEffects({
    this.successFlashEnabled = false,
    this.successFlashColor,
    this.successFlashDuration = const Duration(milliseconds: 220),
  });

  CreativeUIArcProgressEffects copyWith({
    bool? successFlashEnabled,
    Color? successFlashColor,
    Duration? successFlashDuration,
  }) {
    return CreativeUIArcProgressEffects(
      successFlashEnabled: successFlashEnabled ?? this.successFlashEnabled,
      successFlashColor: successFlashColor ?? this.successFlashColor,
      successFlashDuration: successFlashDuration ?? this.successFlashDuration,
    );
  }
}
