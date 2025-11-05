
[![pub package](https://img.shields.io/pub/v/creative_ui_progress.svg)](https://pub.dev/packages/creative_ui_progress)
[![likes](https://img.shields.io/pub/likes/creative_ui_progress)](https://pub.dev/packages/creative_ui_progress/score)
[![pub points](https://img.shields.io/pub/points/creative_ui_progress)](https://pub.dev/packages/creative_ui_progress/score)
[![popularity](https://img.shields.io/pub/popularity/creative_ui_progress)](https://pub.dev/packages/creative_ui_progress/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platforms](https://img.shields.io/badge/platforms-android%20|%20ios%20|%20web%20|%20macos%20|%20windows%20|%20linux-blue)](#)
[![Build](https://github.com/RookiePlayers/creative_ui_progress/actions/workflows/ci.yml/badge.svg)](https://github.com/RookiePlayers/creative_ui_progress/actions)
[![codecov](https://codecov.io/gh/RookiePlayers/creative_ui_progress/branch/main/graph/badge.svg)](https://codecov.io/gh/RookiePlayers/creative_ui_progress)

# Creative UI Progress

Beautiful, animated, and highly customizable progress indicators for Flutter — linear, circular, and arc.

---
## Screenshots
<img width="1197" height="892" alt="Screen Shot 2025-11-05 at 16 15 23 p m" src="https://github.com/user-attachments/assets/2bcb05c7-efd7-45c0-ae04-232a02522598" />
<img width="1192" height="888" alt="Screen Shot 2025-11-05 at 16 15 31 p m" src="https://github.com/user-attachments/assets/64c62bd9-bbda-421a-a686-32a56c02c96b" />
<img width="1196" height="888" alt="Screen Shot 2025-11-05 at 16 15 38 p m" src="https://github.com/user-attachments/assets/9109d329-ac79-4a58-9697-20fe26cdc5e4" />

---

## Features

- ✨ **Linear, Circular, and Arc Progress Indicators**
- 🎨 **Highly customizable styles** (colors, gradients, borders, shapes)
- 🌀 **Smooth animations** (play, pause, reverse, and control progress)
- 💎 **Shimmer and decoration effects**
- 🛠️ **Controller support** for programmatic control
- 🧩 **Discrete steps and continuous modes**
- 🌙 **Dark mode ready**
- ⚡ **Lightweight and easy to use**

---

## Installation

Add Creative UI Progress to your project:

```sh
flutter pub add creative_ui_progress
```

---

## Usage

### Linear Progress Bar

```dart
import 'package:creative_ui_progress/creative_ui_progress.dart';

CreativeUIProgressBar(
  value: 50,
  maxValue: 100,
  height: 12,
  progressColor: Colors.blueAccent,
  backgroundColor: Colors.grey.shade200,
  borderRadius: 8,
)
```

### Circular Progress Indicator

```dart
import 'package:creative_ui_progress/creative_ui_progress.dart';

CreativeUICircularProgress(
  value: 0.7, // 70%
  size: 64,
  strokeWidth: 8,
  progressColor: Colors.purple,
  backgroundColor: Colors.grey.shade300,
  animate: true,
)
```

### Arc Progress Indicator

```dart
import 'package:creative_ui_progress/creative_ui_progress.dart';

CreativeUIArcProgress(
  value: 0.35,
  arcAngle: 240,
  size: 80,
  strokeWidth: 10,
  progressColor: Colors.orange,
  backgroundColor: Colors.black12,
  showText: true,
)
```

---

## Customization

Creative UI Progress offers a rich set of customization options:

- **Styles:** Set colors, gradients, border radius, thickness, shadows, and more.
- **Animations:** Enable/disable animation, set animation duration and curve.
- **Effects:** Add shimmer, glows, or custom decorations to progress or background.
- **Behaviors:** Use continuous or discrete step modes, show/hide percentage text, and more.

### Example: Shimmer & Decoration

```dart
CreativeUIProgressBar(
  value: 80,
  maxValue: 100,
  height: 16,
  progressColor: Colors.green,
  progressDecoration: Shimmer.fromColors(
    baseColor: Colors.green,
    highlightColor: Colors.lightGreenAccent,
    child: Container(),
  ),
  backgroundDecoration: DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.grey.shade200, Colors.grey.shade300],
      ),
    ),
  ),
)
```

---

## Controllers

You can control the progress indicators programmatically using controllers.

```dart
final controller = CreativeUIProgressController();

CreativeUIProgressBar(
  value: 0,
  maxValue: 100,
  controller: controller,
)

// Play/animate to a new value
controller.play(value: 75);

// Pause the animation
controller.pause();

// Resume animation
controller.resume();

// Reverse progress (optional: to a specific value)
controller.reverse(toPercentage: 0.2);
```

---

## License

MIT
