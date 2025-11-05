

import 'package:creative_ui_progress/src/components/linear_progress/options/callbacks.dart';

class CreativeUICircularProgressCallbacks {
  final IntervalCallback? onCompletedInterval;
  final FinalCompletedCallback? onFinalCompleted;

  const CreativeUICircularProgressCallbacks({
    this.onCompletedInterval,
    this.onFinalCompleted,
  });

  CreativeUICircularProgressCallbacks copyWith({
    IntervalCallback? onCompletedInterval,
    FinalCompletedCallback? onFinalCompleted,
  }) {
    return CreativeUICircularProgressCallbacks(
      onCompletedInterval: onCompletedInterval ?? this.onCompletedInterval,
      onFinalCompleted: onFinalCompleted ?? this.onFinalCompleted,
    );
  }
}