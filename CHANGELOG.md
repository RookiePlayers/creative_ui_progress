# Changelog
All notable changes to **creative_ui_progress** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-11-05
### Added
- **Linear Progress (`CreativeUIProgressBar`)**
  - Determinate, looping, and indeterminate modes (LTR/RTL/Ping‑Pong).
  - Controller with `play({percentage|value,max})`, `pause()`, `resume()`, `reverse(toPercentage)`.
  - Discrete steps rendering (`useDiscreteSteps`, `steps`).
  - Success flash effect and callbacks: `onCompletedInterval`, `onFinalCompleted`.
  - `progressDecoration` and `backgroundDecoration` with hard clipping to the bar.
- **Circular Progress (`CreativeUICircularProgress`)**
  - Determinate, looping, and indeterminate modes with configurable sweep and motion.
  - Optional shimmer highlight along the ring (duration, width fraction, curve, color).
  - Supports solid color or `SweepGradient`, start angle, stroke width/cap, and center widget.
  - Controller API mirrors the linear component.
- **Arc Progress (`CreativeUIArcProgress`)**
  - Partial‑circle/arc progress with custom `startAngle` and `arcSweep`.
  - Determinate, looping, and indeterminate (including ping‑pong) modes.
  - Effects and callbacks consistent with other components.

### Fixed
- Clipping/overflow issues where `progressDecoration` did not fully cover the progress fill.
- Edge case where values of `NaN`/`Infinity` or `maxValue == 0` could reset progress unexpectedly.
- Indeterminate animation curve alignment for ping‑pong motion.

### Changed
- Unified animation engines across linear, circular, and arc widgets for consistent behavior.
- Refined `playOnInit` semantics to avoid unintended resets when not animating.

## [0.0.1] - 2025-10-30
### Added
- Initial scaffolding and package setup.
- Basic linear progress prototype.