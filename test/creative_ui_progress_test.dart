import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:creative_ui_progress/creative_ui_progress.dart';

// test/circular_progress_test.dart
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// ---------- Test helpers ----------

Future<ui.Image> _solidImage({int size = 256, Color color = Colors.red}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
  );
  final paint = Paint()..color = color;
  canvas.drawRect(Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), paint);
  final picture = recorder.endRecording();
  return picture.toImage(size, size);
}

Future<Color> _sampleColor(
  WidgetTester tester, {
  required GlobalKey repaintKey,
  required Offset localPoint,
}) async {
  final boundary =
      repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final img = await boundary.toImage(pixelRatio: 1.0);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
  final width = img.width;
  final x = localPoint.dx.clamp(0.0, width - 1.0).toInt();
  final y = localPoint.dy.clamp(0.0, img.height - 1.0).toInt();
  final offset = (y * width + x) * 4;

  // RGBA order in rawRgba
  final r = byteData!.getUint8(offset);
  final g = byteData.getUint8(offset + 1);
  final b = byteData.getUint8(offset + 2);
  final a = byteData.getUint8(offset + 3);

  return Color.fromARGB(a, r, g, b);
}

double _luminance(Color c) => c.computeLuminance();

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(
    backgroundColor: Colors.black, // make "hollow center" easy to detect
    body: Center(child: child),
  ),
);

/// Convenience to place a repaint boundary around the progress
Widget _circularUnderTest({
  required GlobalKey repaintKey,
  required CreativeUICircularProgressOptions options,
  double pad = 0,
}) {
  return _wrap(
    RepaintBoundary(
      key: repaintKey,
      child: Padding(
        padding: EdgeInsets.all(pad),
        child: CreativeUICircularProgress(options: options),
      ),
    ),
  );
}

/// Get a point along the ring’s middle radius at a given absolute canvas angle.
/// Angle 0 = +X axis (to the right). We’ll pass -π/2 to sample “top-center”.
Offset _pointOnRing({
  required double size,
  required double stroke,
  required double angle,
}) {
  final rOuter = size / 2;
  final r = rOuter - stroke / 2;
  final cx = size / 2;
  final cy = size / 2;
  return Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreativeUICircularProgress — shimmer + decoration', () {
    testWidgets('Shimmer starts at top-center when startAngle = -π/2', (
      tester,
    ) async {
      final key = GlobalKey();
      const size = 120.0;
      const stroke = 12.0;

      // We paint a bright blue arc, then a white shimmer band; at t=0 the shimmer
      // sits at the arc start. With startAngle = -π/2, that’s the top-center.
      await tester.pumpWidget(
        _circularUnderTest(
          repaintKey: key,
          options: CreativeUICircularProgressOptions(
            styles: const CreativeUICircularProgressStyles(
              size: size,
              strokeWidth: stroke,
              progressColor: Colors.blue,
              backgroundColor: Colors.black26,
              startAngle: -math.pi / 2, // TOP-CENTER
            ),
            behavior: const CreativeUICircularProgressBehavior(
              value: 0.75,
              maxValue: 1.0,
              playOnInit: true,
            ),
            animation: const CreativeUICircularProgressAnimation(
              shimmerEnabled: true,
              shimmerColor: Colors.white,
              shimmerWidthFraction: 0.35,
              shimmerDuration: Duration(milliseconds: 1600),
              // default mode is fine for this check
            ),
          ),
        ),
      );

      // First frame (t≈0): shimmer band should brighten the top-center compared to left-center
      final top = await _sampleColor(
        tester,
        repaintKey: key,
        localPoint: _pointOnRing(
          size: size,
          stroke: stroke,
          angle: -math.pi / 2,
        ),
      );
      final left = await _sampleColor(
        tester,
        repaintKey: key,
        localPoint: _pointOnRing(size: size, stroke: stroke, angle: math.pi),
      );

      // Top should be brighter due to shimmer peak
      expect(
        _luminance(top) > _luminance(left),
        isTrue,
        reason:
            'Top-center should be brighter than left-center at shimmer start.',
      );
    });

    testWidgets(
      'Progress decoration image is clipped to the ring (center remains hollow)',
      (tester) async {
        final key = GlobalKey();
        const size = 140.0;
        const stroke = 20.0;

        // Make a vivid red image to use as decoration
        final img = await _solidImage(color: Colors.red);
        final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
        final provider = MemoryImage(Uint8List.view(byteData!.buffer));

        await tester.pumpWidget(
          _circularUnderTest(
            repaintKey: key,
            options: CreativeUICircularProgressOptions(
              styles: CreativeUICircularProgressStyles(
                size: size,
                strokeWidth: stroke,
                progressColor:
                    Colors.transparent, // image should visually replace color
                backgroundColor: Colors.grey.shade800,
                startAngle: -math.pi / 2,
                progressDecorationImage: provider,
                progressDecorationOpaque:
                    true, // draw only the image on the ring
              ),
              behavior: const CreativeUICircularProgressBehavior(
                value: 0.6,
                maxValue: 1.0,
                playOnInit: true,
              ),
              animation: const CreativeUICircularProgressAnimation(
                shimmerEnabled: false,
              ),
            ),
          ),
        );

        // Sample center (should be scaffold black, i.e., hollow center; not red)
        final center = await _sampleColor(
          tester,
          repaintKey: key,
          localPoint: const Offset(size / 2, size / 2),
        );

        // Sample top ring (should be red from the decoration image)
        final topRing = await _sampleColor(
          tester,
          repaintKey: key,
          localPoint: _pointOnRing(
            size: size,
            stroke: stroke,
            angle: -math.pi / 2,
          ),
        );

        // Center should be dark (near black), ring should be red
        expect(
          _luminance(center) < 0.15,
          true,
          reason:
              'Center should remain hollow/dark (clipped image not filling center).',
        );
        expect(
          topRing.r > 200 && topRing.g < 60 && topRing.b < 60,
          true,
          reason: 'Ring area should show the red decoration image.',
        );
      },
    );

    testWidgets('Shimmer modes: once, count(2), continuous', (tester) async {
      const size = 120.0;
      const stroke = 12.0;

      Future<List<double>> lumsFor({
        required ShimmerMode mode,
        int shimmerCount = 2,
      }) async {
        final key = GlobalKey();
        await tester.pumpWidget(
          _circularUnderTest(
            repaintKey: key,
            options: CreativeUICircularProgressOptions(
              styles: const CreativeUICircularProgressStyles(
                size: size,
                strokeWidth: stroke,
                progressColor: Colors.blue,
                backgroundColor: Colors.black26,
                startAngle: -math.pi / 2,
              ),
              behavior: const CreativeUICircularProgressBehavior(
                value: 0.75,
                maxValue: 1.0,
                playOnInit: true,
              ),
              animation: CreativeUICircularProgressAnimation(
                shimmerEnabled: true,
                shimmerColor: Colors.white,
                shimmerWidthFraction: 0.3,
                shimmerDuration: const Duration(milliseconds: 800),
                shimmerMode: mode,
                shimmerCount: shimmerCount,
                shimmerPause: const Duration(milliseconds: 80),
              ),
            ),
          ),
        );

        // Sample the top pixel over time to see if luminance keeps changing
        final samples = <double>[];
        // Measure over ~2.2 seconds total
        for (var i = 0; i < 11; i++) {
          await tester.pump(const Duration(milliseconds: 200));
          final c = await _sampleColor(
            tester,
            repaintKey: key,
            localPoint: _pointOnRing(
              size: size,
              stroke: stroke,
              angle: -math.pi / 2,
            ),
          );
          samples.add(_luminance(c));
        }
        return samples;
      }

      // once: should change early, then stabilize (no ongoing variation)
      final once = await lumsFor(mode: ShimmerMode.once);
      final onceVarianceLate = (once.sublist(6)..sort());
      // Range late should be small
      expect(
        onceVarianceLate.last - onceVarianceLate.first < 0.03,
        true,
        reason: 'Shimmer(once) should stop and stabilize after one pass.',
      );

      // count(2): should show variation for a bit longer than once, then stabilize
      final count = await lumsFor(mode: ShimmerMode.count, shimmerCount: 2);
      final countEarlyRange = (() {
        final s = (count.sublist(0, 6)..sort());
        return s.last - s.first;
      })();
      final countLateRange = (() {
        final s = (count.sublist(7)..sort());
        return s.last - s.first;
      })();
      expect(
        countEarlyRange > 0.05,
        true,
        reason: 'Shimmer(count=2) should animate early.',
      );
      expect(
        countLateRange < 0.03,
        true,
        reason: 'Shimmer(count=2) should stop later and stabilize.',
      );

      // continuous: should keep varying throughout
      final cont = await lumsFor(mode: ShimmerMode.continuous);
      final contRange = (() {
        final s = (cont..sort());
        return s.last - s.first;
      })();
      expect(
        contRange > 0.08,
        true,
        reason: 'Shimmer(continuous) should continue varying over time.',
      );
    });
  });
}
