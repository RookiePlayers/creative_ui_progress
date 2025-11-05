import 'package:creative_ui_progress/src/components/linear_progress/options/callbacks.dart';

class CreativeUIArcProgressCallbacks {
  final IntervalCallback? onCompletedInterval;
  final FinalCompletedCallback? onFinalCompleted;

  const CreativeUIArcProgressCallbacks({
    this.onCompletedInterval,
    this.onFinalCompleted,
  });

  CreativeUIArcProgressCallbacks copyWith({
    IntervalCallback? onCompletedInterval,
    FinalCompletedCallback? onFinalCompleted,
  }) {
    return CreativeUIArcProgressCallbacks(
      onCompletedInterval: onCompletedInterval ?? this.onCompletedInterval,
      onFinalCompleted: onFinalCompleted ?? this.onFinalCompleted,
    );
  }
}
