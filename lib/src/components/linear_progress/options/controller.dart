import 'package:flutter/foundation.dart';

/// A controller that provides imperative control over a [CreativeUIProgressBar].
///
/// This allows external widgets, animations, or user interactions to
/// start, pause, resume, or reverse the progress animation at runtime.
///
/// Typically passed to a [CreativeUIProgressBar] via its `controller` parameter.
///
/// ```dart
/// final controller = CreativeUIProgressBarController();
///
/// CreativeUIProgressBar(
///   controller: controller,
///   options: CreativeUIProgressOptions(...),
/// );
///
/// // Later in your code:
/// controller.play(value: 75, max: 100);   // animate to 75%
/// controller.pause();                     // pause the animation
/// controller.resume();                    // resume after pause
/// controller.reverse(toPercentage: 0.2);  // animate back to 20%
/// ```
class CreativeUIProgressBarController {
  /// Starts or restarts the progress animation toward a target percentage or value.
  ///
  /// You can specify one of:
  /// - [percentage]: a normalized value between 0.0 and 1.0
  /// - [value] and optionally [max]: absolute values that are converted to a percentage
  ///
  /// If the associated [CreativeUIProgressBar] has looping enabled,
  /// values greater than 100% (e.g., `value > max`) will loop through intervals,
  /// triggering `onCompletedInterval` after each full bar fill.
  ///
  /// Example:
  /// ```dart
  /// controller.play(value: 250, max: 100); // plays 2 full loops + 50%
  /// ```
  void Function({double? percentage, double? value, double? max}) play =
      ({double? percentage, double? value, double? max}) {};

  /// Immediately pauses the current progress animation.
  ///
  /// If the bar is in an indeterminate or shimmer mode, this stops the shimmer loop as well.
  VoidCallback pause = () {};

  /// Resumes a paused animation or shimmer loop from where it stopped.
  ///
  /// Has no effect if the progress bar is idle or already running.
  VoidCallback resume = () {};

  /// Reverses the progress bar animation down to a specific percentage.
  ///
  /// The optional [toPercentage] argument defines the target value (0.0–1.0).
  /// If omitted, it reverses to 0%.
  ///
  /// Example:
  /// ```dart
  /// controller.reverse(toPercentage: 0.25); // animates down to 25%
  /// ```
  void Function({double? toPercentage}) reverse = ({double? toPercentage}) {};
}