class CreativeUIProgressBarBehavior {
  final num value;
  final num maxValue;

  /// Start animating to [value/maxValue] on mount.
  final bool playOnInit;

  /// If true, allows values > 100% (loops), emitting onCompletedInterval per full 100%.
  final bool loopEnabled;

  /// Snap to discrete steps visually.
  final bool useDiscreteSteps;
  final int steps;

  /// If true, ignore value/max and show indeterminate animation.
  final bool indeterminate;

  const CreativeUIProgressBarBehavior({
    required this.value,
    required this.maxValue,
    this.playOnInit = false,
    this.loopEnabled = true,
    this.useDiscreteSteps = false,
    this.steps = 10,
    this.indeterminate = false,
  });

  CreativeUIProgressBarBehavior copyWith({
    num? value,
    num? maxValue,
    bool? playOnInit,
    bool? loopEnabled,
    bool? useDiscreteSteps,
    int? steps,
    bool? indeterminate,
  }) {
    return CreativeUIProgressBarBehavior(
      value: value ?? this.value,
      maxValue: maxValue ?? this.maxValue,
      playOnInit: playOnInit ?? this.playOnInit,
      loopEnabled: loopEnabled ?? this.loopEnabled,
      useDiscreteSteps: useDiscreteSteps ?? this.useDiscreteSteps,
      steps: steps ?? this.steps,
      indeterminate: indeterminate ?? this.indeterminate,
    );
  }
}
