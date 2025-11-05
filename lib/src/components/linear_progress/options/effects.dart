import 'package:flutter/material.dart';

class CreativeUIProgressEffects {
  final bool successFlashEnabled;
  final Color? successFlashColor;
  final Duration successFlashDuration;

  const CreativeUIProgressEffects({
    this.successFlashEnabled = false,
    this.successFlashColor,
    this.successFlashDuration = const Duration(milliseconds: 240),
  });

  CreativeUIProgressEffects copyWith({
    bool? successFlashEnabled,
    Color? successFlashColor,
    Duration? successFlashDuration,
  }) =>
      CreativeUIProgressEffects(
        successFlashEnabled: successFlashEnabled ?? this.successFlashEnabled,
        successFlashColor: successFlashColor ?? this.successFlashColor,
        successFlashDuration: successFlashDuration ?? this.successFlashDuration,
      );
}