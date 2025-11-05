class CreativeUIArcProgressBehavior {
  final num value;
  final num maxValue;

  /// Start animating on mount
  final bool playOnInit;

  /// Values >100% loop and emit onCompletedInterval per full arc
  final bool loopEnabled;

  /// Snap to discrete steps
  final bool useDiscreteSteps;
  final int steps;

  /// Ignore value/max and show infinite animation
  final bool indeterminate;

  const CreativeUIArcProgressBehavior({
    required this.value,
    required this.maxValue,
    this.playOnInit = false,
    this.loopEnabled = true,
    this.useDiscreteSteps = false,
    this.steps = 12,
    this.indeterminate = false,
  });

  CreativeUIArcProgressBehavior copyWith({
    num? value,
    num? maxValue,
    bool? playOnInit,
    bool? loopEnabled,
    bool? useDiscreteSteps,
    int? steps,
    bool? indeterminate,
  }) {
    return CreativeUIArcProgressBehavior(
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
