import 'package:flutter/material.dart';

class CreativeUICircularProgressEffects {
  final bool successFlashEnabled;
  final Color? successFlashColor;
  final Duration successFlashDuration;

  const CreativeUICircularProgressEffects({
    this.successFlashEnabled = false,
    this.successFlashColor,
    this.successFlashDuration = const Duration(milliseconds: 240),
  });

  CreativeUICircularProgressEffects copyWith({
    bool? successFlashEnabled,
    Color? successFlashColor,
    Duration? successFlashDuration,
  }) {
    return CreativeUICircularProgressEffects(
      successFlashEnabled: successFlashEnabled ?? this.successFlashEnabled,
      successFlashColor: successFlashColor ?? this.successFlashColor,
      successFlashDuration: successFlashDuration ?? this.successFlashDuration,
    );
  }
}