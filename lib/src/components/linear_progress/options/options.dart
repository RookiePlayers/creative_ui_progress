

import 'package:creative_ui_progress/src/components/linear_progress/options/animation.dart';
import 'package:creative_ui_progress/src/components/linear_progress/options/behaviour.dart';
import 'package:creative_ui_progress/src/components/linear_progress/options/callbacks.dart';
import 'package:creative_ui_progress/src/components/linear_progress/options/effects.dart';
import 'package:creative_ui_progress/src/components/linear_progress/options/style.dart';

class CreativeUIProgressBarOptions {
  final CreativeUIProgressBarStyles styles;
  final CreativeUIProgressBarBehavior behavior;
  final CreativeUIProgressBarAnimation animation;
  final CreativeUIProgressEffects effects;
  final CreativeUIProgressBarCallbacks callbacks;

  const CreativeUIProgressBarOptions({
    required this.styles,
    required this.behavior,
    this.animation = const CreativeUIProgressBarAnimation(),
    this.effects = const CreativeUIProgressEffects(),
    this.callbacks = const CreativeUIProgressBarCallbacks(),
  });

  CreativeUIProgressBarOptions copyWith({
    CreativeUIProgressBarStyles? style,
    CreativeUIProgressBarBehavior? behavior,
    CreativeUIProgressBarAnimation? animation,
    CreativeUIProgressEffects? effects,
    CreativeUIProgressBarCallbacks? callbacks,
  }) =>
      CreativeUIProgressBarOptions(
        styles: styles,
        behavior: behavior ?? this.behavior,
        animation: animation ?? this.animation,
        effects: effects ?? this.effects,
        callbacks: callbacks ?? this.callbacks,
      );
}