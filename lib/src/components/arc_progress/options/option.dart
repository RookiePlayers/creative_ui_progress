import 'package:creative_ui_progress/src/components/arc_progress/options/animation.dart';
import 'package:creative_ui_progress/src/components/arc_progress/options/behaviour.dart';
import 'package:creative_ui_progress/src/components/arc_progress/options/callbacks.dart';
import 'package:creative_ui_progress/src/components/arc_progress/options/effects.dart';
import 'package:creative_ui_progress/src/components/arc_progress/options/styles.dart';

class CreativeUIArcProgressOptions {
  final CreativeUIArcProgressStyles styles;
  final CreativeUIArcProgressBehavior behavior;
  final CreativeUIArcProgressAnimation animation;
  final CreativeUIArcProgressEffects effects;
  final CreativeUIArcProgressCallbacks callbacks;

  const CreativeUIArcProgressOptions({
    required this.styles,
    required this.behavior,
    this.animation = const CreativeUIArcProgressAnimation(),
    this.effects = const CreativeUIArcProgressEffects(),
    this.callbacks = const CreativeUIArcProgressCallbacks(),
  });

  CreativeUIArcProgressOptions copyWith({
    CreativeUIArcProgressStyles? styles,
    CreativeUIArcProgressBehavior? behavior,
    CreativeUIArcProgressAnimation? animation,
    CreativeUIArcProgressEffects? effects,
    CreativeUIArcProgressCallbacks? callbacks,
  }) {
    return CreativeUIArcProgressOptions(
      styles: styles ?? this.styles,
      behavior: behavior ?? this.behavior,
      animation: animation ?? this.animation,
      effects: effects ?? this.effects,
      callbacks: callbacks ?? this.callbacks,
    );
  }
}
