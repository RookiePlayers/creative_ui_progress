typedef IntervalCallback = void Function();
typedef FinalCompletedCallback = void Function(bool levelup);

class CreativeUIProgressBarCallbacks {
  final IntervalCallback? onCompletedInterval;
  final FinalCompletedCallback? onFinalCompleted;

  const CreativeUIProgressBarCallbacks({
    this.onCompletedInterval,
    this.onFinalCompleted,
  });

  CreativeUIProgressBarCallbacks copyWith({
    IntervalCallback? onCompletedInterval,
    FinalCompletedCallback? onFinalCompleted,
  }) {
    return CreativeUIProgressBarCallbacks(
      onCompletedInterval: onCompletedInterval ?? this.onCompletedInterval,
      onFinalCompleted: onFinalCompleted ?? this.onFinalCompleted,
    );
  }
}
