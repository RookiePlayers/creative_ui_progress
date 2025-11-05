class CreativeUICircularProgressBehavior {
  final num value;
  final num maxValue;

  /// Start animating on mount toward [value/maxValue].
  final bool playOnInit;

  /// If true, values >100% loop and emit onCompletedInterval per full circle.
  final bool loopEnabled;

  /// Snap to discrete steps visually.
  final bool useDiscreteSteps;
  final int steps;

  /// If true, ignore value/max and show infinite spinner.
  final bool indeterminate;

  const CreativeUICircularProgressBehavior({
    required this.value,
    required this.maxValue,
    this.playOnInit = false,
    this.loopEnabled = true,
    this.useDiscreteSteps = false,
    this.steps = 12,
    this.indeterminate = false,
  });

  CreativeUICircularProgressBehavior copyWith({
    num? value,
    num? maxValue,
    bool? playOnInit,
    bool? loopEnabled,
    bool? useDiscreteSteps,
    int? steps,
    bool? indeterminate,
  }) {
    return CreativeUICircularProgressBehavior(
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