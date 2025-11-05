import 'package:creative_ui_progress/src/components/circular_progress/options/animation.dart';
import 'package:creative_ui_progress/src/components/circular_progress/options/behaviour.dart';
import 'package:creative_ui_progress/src/components/circular_progress/options/callbacks.dart';
import 'package:creative_ui_progress/src/components/circular_progress/options/effects.dart';
import 'package:creative_ui_progress/src/components/circular_progress/options/styles.dart';

class CreativeUICircularProgressOptions {
  final CreativeUICircularProgressStyles styles;
  final CreativeUICircularProgressBehavior behavior;
  final CreativeUICircularProgressAnimation animation;
  final CreativeUICircularProgressEffects effects;
  final CreativeUICircularProgressCallbacks callbacks;

  const CreativeUICircularProgressOptions({
    required this.styles,
    required this.behavior,
    this.animation = const CreativeUICircularProgressAnimation(),
    this.effects = const CreativeUICircularProgressEffects(),
    this.callbacks = const CreativeUICircularProgressCallbacks(),
  });

  CreativeUICircularProgressOptions copyWith({
    CreativeUICircularProgressStyles? styles,
    CreativeUICircularProgressBehavior? behavior,
    CreativeUICircularProgressAnimation? animation,
    CreativeUICircularProgressEffects? effects,
    CreativeUICircularProgressCallbacks? callbacks,
  }) {
    return CreativeUICircularProgressOptions(
      styles: styles ?? this.styles,
      behavior: behavior ?? this.behavior,
      animation: animation ?? this.animation,
      effects: effects ?? this.effects,
      callbacks: callbacks ?? this.callbacks,
    );
  }
}
