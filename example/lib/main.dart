import 'dart:math' as math;
import 'package:creative_ui_progress/creative_ui_progress.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Creative UI Progress Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProgressDemoPage(),
    );
  }
}

class ProgressDemoPage extends StatefulWidget {
  const ProgressDemoPage({super.key});

  @override
  State<ProgressDemoPage> createState() => _ProgressDemoPageState();
}

class _ProgressDemoPageState extends State<ProgressDemoPage> {
  double _progress = 0.3;
  final controller = CreativeUIProgressBarController();
  final circularController = CreativeUICircularProgressController();
  final arcCtrl = CreativeUIArcProgressController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Creative UI Progress Example'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Linear Progress'),
              Tab(text: 'Circular Progress'),
              Tab(text: 'Arc Progress'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Linear Progress Page
            _buildLinear(),
            // Circular Progress Page
            _buildCircular(context),
            // Arc Progress Page
            _buildArc(context),
          ],
        ),
      ),
    );
  }

  Center _buildLinear() {
    return Center(
      child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 2.8,
        ),
        children: [
        Card(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('DETERMINATE(LTR)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            CreativeUIProgressBar(
                options: CreativeUIProgressBarOptions(
                  styles: const CreativeUIProgressBarStyles(
                    width: 250,
                    height: 10,
                    progressColor: Colors.green,
                    backgroundColor: Colors.black12,
                  ),
                  behavior: const CreativeUIProgressBarBehavior(
                    value: 40,
                    maxValue: 100,
                    playOnInit: true,
                  ),
                ),
              )
          ],
          ),
        ),
        Card(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('DETERMINATE (RTL)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
           CreativeUIProgressBar(
              options: CreativeUIProgressBarOptions(
                styles: const CreativeUIProgressBarStyles(
                  width: 250,
                  height: 10,
                  progressColor: Colors.blueAccent,
                  backgroundColor: Colors.grey,
                  progressDirection: ProgressDirection.rtl,
                ),
                behavior: const CreativeUIProgressBarBehavior(
                  value: 70,
                  maxValue: 100,
                  playOnInit: true,
                  loopEnabled: false,
                ),
                animation: const CreativeUIProgressBarAnimation(
                  progressDuration: Duration(milliseconds: 400),
                  progressCurve: Curves.easeOutCubic,
                ),
              ),
            )
          ],
          ),
        ),
        Card(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('LOOPING PROGRESSION', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            CreativeUIProgressBar(
              options: CreativeUIProgressBarOptions(
                styles: const CreativeUIProgressBarStyles(
                  width: 250,
                  height: 12,
                  progressColor: Colors.purple,
                  backgroundColor: Colors.black26,
                ),
                behavior: const CreativeUIProgressBarBehavior(
                  value: 320,
                  maxValue: 100,
                  loopEnabled: true,   // loops 3 times, fires interval callback each time
                  playOnInit: true,
                ),
                callbacks: CreativeUIProgressBarCallbacks(
                  onCompletedInterval: () => debugPrint("Interval completed!"),
                  onFinalCompleted: (levelUp) => debugPrint("Finished looping, levelUp: $levelUp"),
                ),
              ),
            ),
          ],
          ),
        ),
        Card(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('INDETERMINATE (LTR)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
           CreativeUIProgressBar(
            options: CreativeUIProgressBarOptions(
              styles: const CreativeUIProgressBarStyles(
                width: 250,
                height: 8,
                progressColor: Colors.orange,
                backgroundColor: Colors.black26,
              ),
              behavior: const CreativeUIProgressBarBehavior(
                value: 0,
                maxValue: 0,
                indeterminate: true,
              ),
              animation: const CreativeUIProgressBarAnimation(
                indeterminateMotion: IndeterminateMotion.ltr,
                indeterminateSpeedCps: 1.5, // ~1.5 sweeps/sec
                indeterminateHeadFraction: 0.25,
              ),
            ),
          )
          ],
          ),
        ),
        Card(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('INDETERMINATE (PING-PONG)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
           CreativeUIProgressBar(
                options: CreativeUIProgressBarOptions(
                  styles: const CreativeUIProgressBarStyles(
                    width: 250,
                    height: 8,
                    progressColor: Colors.redAccent,
                    backgroundColor: Colors.grey,
                  ),
                  behavior: const CreativeUIProgressBarBehavior(
                    value: 0,
                    maxValue: 0,
                    indeterminate: true,
                  ),
                  animation: const CreativeUIProgressBarAnimation(
                    indeterminateMotion: IndeterminateMotion.pingPong,
                    indeterminateDuration: Duration(milliseconds: 900),
                  ),
                ),
              )
          ],
          ),
        ),
        Card(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('SUCCESS FLASH', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
           CreativeUIProgressBar(
            options: CreativeUIProgressBarOptions(
              styles: const CreativeUIProgressBarStyles(
                width: 250,
                height: 10,
                progressColor: Colors.amber,
                backgroundColor: Colors.black12,
              ),
              behavior: const CreativeUIProgressBarBehavior(
                value: 100,
                maxValue: 100,
                playOnInit: true,
                loopEnabled: false,
              ),
              effects: const CreativeUIProgressEffects(
                successFlashEnabled: true,
                successFlashColor: Colors.white70,
                successFlashDuration: Duration(milliseconds: 300),
              ),
            ),
          )
          ],
          ),
        ),
        Card(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('CONTROLLED', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            CreativeUIProgressBar(
                  controller: controller,
                  options: CreativeUIProgressBarOptions(
                    styles: const CreativeUIProgressBarStyles(
                      width: 250,
                       height: 10,
                      borderRadius: 8,
                      progressColor: Colors.deepPurple,
                      backgroundColor: Colors.black12,
                    ),
                    behavior: const CreativeUIProgressBarBehavior(
                      value: 30,
                      maxValue: 100,
                      loopEnabled: true,
                      playOnInit: true,
                    ),
                    animation: const CreativeUIProgressBarAnimation(
                      shimmerEnabled: true,
                      
                    ),
                    effects: const CreativeUIProgressEffects(
                    ),
                    callbacks: CreativeUIProgressBarCallbacks(
                      onCompletedInterval: () => debugPrint('Loop completed!'),
                    ),
                  ),
                ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => controller.play(value: 50, max: 100),
              child: const Text("Animate to 50%"),
            ),
          ],
          ),
        ),
        
        Card(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('BACKGROUNDS', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            CreativeUIProgressBar(
                  controller: controller,
                  options: CreativeUIProgressBarOptions(
                    styles:  CreativeUIProgressBarStyles(
                      width: 250,
                       height: 10,
                      borderRadius: 8,
                      progressColor: Colors.deepPurple,
                      backgroundColor: Colors.black12,
                    ),
                    behavior: const CreativeUIProgressBarBehavior(
                      value: 30,
                      maxValue: 100,
                      loopEnabled: true,
                      playOnInit: true,
                    ),
                    animation: const CreativeUIProgressBarAnimation(
                      
                    ),
                    effects: const CreativeUIProgressEffects(
                    ),
                    callbacks: CreativeUIProgressBarCallbacks(
                      onCompletedInterval: () => debugPrint('Loop completed!'),
                    ),
                  ),
                ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => controller.play(value: 50, max: 100),
              child: const Text("Animate to 50%"),
            ),
          ],
          ),
        ),
        
        ],
      ),
      ),
    );
  }

  Center _buildCircular(BuildContext context) {
    return Center(
      child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 1.5,
        ),
        children: [
        Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text('Progress: ${(_progress * 100).toInt()}%'),
            const SizedBox(height: 12),
            Text('DETERMINATE', style: Theme.of(context).textTheme.titleMedium),
            CreativeUICircularProgress(
              options: CreativeUICircularProgressOptions(
                styles: CreativeUICircularProgressStyles(
                  size: 90,
                  strokeWidth: 10,
                  progressColor: Colors.tealAccent,
                  backgroundColor: Colors.black12,
                ),
                behavior: const CreativeUICircularProgressBehavior(
                  value: 60,
                  maxValue: 100,
                  playOnInit: true,
                ),
                animation: const CreativeUICircularProgressAnimation(
                  shimmerEnabled: false,
                ),
              ),
            )
            ],
          ),
        ),
        Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text('Progress: ${(_progress * 100).toInt()}%'),
            const SizedBox(height: 12),
            Text('DETERMINATE WITH SHIMMER', style: Theme.of(context).textTheme.titleMedium),
           CreativeUICircularProgress(
            options: CreativeUICircularProgressOptions(
              styles: CreativeUICircularProgressStyles(
                size: 100,
                strokeWidth: 12,
                progressColor: Colors.deepPurple,
                backgroundColor: Colors.grey.shade900,
                startAngle: -math.pi / 2,
                center: const Text(
                  "72%",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              behavior: const CreativeUICircularProgressBehavior(
                value: 70,
                maxValue: 100,
                playOnInit: true,
              ),
              animation: const CreativeUICircularProgressAnimation(
                shimmerEnabled: true,
                shimmerDuration: Duration(milliseconds: 1800),
                shimmerColor: Colors.white70,
                shimmerWidthFraction: 0.25,
                shimmerCurve: Curves.easeInOut,
              ),
            ),
          )
            ],
          ),
        ),
        Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text('Progress: ${(_progress * 100).toInt()}%'),
            const SizedBox(height: 12),
            Text('PROGRESS DECORATION', style: Theme.of(context).textTheme.titleMedium),
          CreativeUICircularProgress(
              options: CreativeUICircularProgressOptions(
                styles: CreativeUICircularProgressStyles(
                  size: 120,
                  strokeWidth: 14,
                  progressDecorationImage: NetworkImage("https://media.istockphoto.com/id/1490912792/vector/gradient-pride-colors-lgbtqia-rainbow-colors.jpg?s=612x612&w=0&k=20&c=wxAb1FCed3SzcDM2PIbFXskMW5hd85f-0ojlnRAEyB0="),
                  backgroundColor: Colors.black26,
                  strokeCap: StrokeCap.round,
                ),
                behavior: const CreativeUICircularProgressBehavior(
                  value: 85,
                  maxValue: 100,
                  playOnInit: true,
                ),
                animation: const CreativeUICircularProgressAnimation(
                  shimmerEnabled: false,
                ),
              ),
            )
            ],
          ),
        ),
        Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text('Progress: ${(_progress * 100).toInt()}%'),
            const SizedBox(height: 12),
            Text('LOOPING 2 Times', style: Theme.of(context).textTheme.titleMedium),
          CreativeUICircularProgress(
            options: CreativeUICircularProgressOptions(
              styles: CreativeUICircularProgressStyles(
                size: 100,
                strokeWidth: 8,
                progressColor: Colors.orangeAccent,
                backgroundColor: Colors.black12,
              ),
              behavior: const CreativeUICircularProgressBehavior(
                value: 200,
                maxValue: 100,
                loopEnabled: true,
                playOnInit: true,
              ),
              effects: const CreativeUICircularProgressEffects(
                successFlashEnabled: true,
                successFlashColor: Colors.orangeAccent,
              ),
            ),
          )
            ],
          ),
        ),
        Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text('INDETERMINATE', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    // Ping-Pong (back-and-forth motion)
    Flexible(
      child: CreativeUICircularProgress(
        options: CreativeUICircularProgressOptions(
          styles: CreativeUICircularProgressStyles(
            size: 80,
            strokeWidth: 10,
            progressColor: Colors.cyanAccent,
          ),
          behavior: const CreativeUICircularProgressBehavior(
            value: 0,
            maxValue: 100,
            indeterminate: true,
          ),
          animation: const CreativeUICircularProgressAnimation(
            indeterminateMotion: IndeterminateMotion.pingPong,
          )
        ),
      ),
    ),

    const SizedBox(height: 20),

    // Continuous clockwise (LTR)
    Flexible(
      child: CreativeUICircularProgress(
        options: CreativeUICircularProgressOptions(
          styles: CreativeUICircularProgressStyles(
            size: 80,
            strokeWidth: 10,
            progressColor: Colors.pinkAccent,
          ),
          behavior: const CreativeUICircularProgressBehavior(
            value: 0,
            maxValue: 100,
            indeterminate: true,
          ),
          animation: const CreativeUICircularProgressAnimation(
            indeterminateMotion: IndeterminateMotion.ltr,
          ),
        ),
      ),
    ),

    const SizedBox(height: 20),

    // Continuous counter-clockwise (RTL)
    Flexible(
      child: CreativeUICircularProgress(
        options: CreativeUICircularProgressOptions(
          styles: CreativeUICircularProgressStyles(
            size: 80,
            strokeWidth: 10,
            progressColor: Colors.greenAccent,
          ),
          behavior: const CreativeUICircularProgressBehavior(
            indeterminate: true,
            value: 0,
            maxValue: 100,
          ),
          animation: const CreativeUICircularProgressAnimation(
            indeterminateMotion: IndeterminateMotion.rtl,
          ),
        ),
      ),
    ),
  ],
)
            ],
          ),
        ),
        Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text('INDETERMINATE(FAST)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            CreativeUICircularProgress(
              options: CreativeUICircularProgressOptions(
              styles: const CreativeUICircularProgressStyles(
                size: 48,
                progressColor: Colors.teal,
              ),
              behavior: const CreativeUICircularProgressBehavior(
                value: 0, maxValue: 0, indeterminate: true, // ⬅️
              ),
              animation: const CreativeUICircularProgressAnimation(
                indeterminateRotationDuration: Duration(milliseconds: 900),
                indeterminateSweepFraction: 0.35, indeterminateMotion: IndeterminateMotion.ltr,
                indeterminateSpeedCps: 2.0, // 2 cycles per second
              ),
              ),
            ),
            ],
          ),
        ),
        Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text("CONTROLLABLE", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            CreativeUICircularProgress(
              controller: circularController,
              options: CreativeUICircularProgressOptions(
                styles: CreativeUICircularProgressStyles(
                  size: 90,
                  strokeWidth: 10,
                  progressGradient: SweepGradient(
                    colors: [Colors.blue, Colors.purple, Colors.pink],
                  ),
                ),
                behavior: const CreativeUICircularProgressBehavior(
                  value: 20,
                  maxValue: 100,
                  loopEnabled: false,
                  playOnInit: true
                ),
                animation: const CreativeUICircularProgressAnimation(
                  shimmerEnabled: true,
                  shimmerColor: Colors.white,
                  shimmerWidthFraction: 0.34,
                  shimmerDuration: Duration(seconds: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => circularController.play(value: 100, max: 100),
                  child: const Text("Play"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => circularController.reverse(toPercentage: 0),
                  child: const Text("Reset"),
                ),
              ],
            ),
            ],
          ),
        ),
        ],
      ),
      ),
    );
  }

  Center _buildArc(BuildContext context) {
    return Center(
      child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 1.5,
        ),
        children: [
        Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text('Progress: ${(_progress * 100).toInt()}%'),
            const SizedBox(height: 12),
            Text('DETERMINATE', style: Theme.of(context).textTheme.titleMedium),
            CreativeUIArcProgress(
              options: CreativeUIArcProgressOptions(
                styles: CreativeUIArcProgressStyles(
                  size: 96,
                  strokeWidth: 10,
                  startAngle: -math.pi * 3/4,  // start at ~225°
                  arcSweep: math.pi * 1.5,     // 270°
                  progressColor: Colors.indigo,
                  trackColor: Colors.black12,
                  center: const Text('75%', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                behavior: const CreativeUIArcProgressBehavior(
                  value: 75,
                  maxValue: 100,
                  loopEnabled: false,
                  playOnInit: true,
                  useDiscreteSteps: true,
                  steps: 20,
                ),
                effects: const CreativeUIArcProgressEffects(
                  successFlashEnabled: true,
                ),
              ),
            ),
            ],
          ),
        ),
        Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text('INDETERMINATE', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            CreativeUIArcProgress(
                options: CreativeUIArcProgressOptions(
                  styles: const CreativeUIArcProgressStyles(
                    size: 64,
                    progressColor: Colors.teal,
                    startAngle: (math.pi), // 270 degrees
                    arcSweep: math.pi, // half-circle sweep
                  ),
                  behavior: const CreativeUIArcProgressBehavior(
                    value: 0, maxValue: 0, indeterminate: true,
                  ),
                  animation: const CreativeUIArcProgressAnimation(
                    indeterminateRotationDuration: Duration(milliseconds: 900),
                    indeterminateSweepFraction: 0.4, // 40% of arcSweep
                    indeterminateMotion: IndeterminateMotion.ltr, // ⬅️
                    indeterminateSpeedCps: 0.8, // 1 cycle per second
                  ),
                ),
              )
            ],
          ),
        ),
        Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text('INDETERMINATE (FAST)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            CreativeUIArcProgress(
                options: CreativeUIArcProgressOptions(
                  styles: const CreativeUIArcProgressStyles(
                    size: 64,
                    progressColor: Colors.teal,
                    startAngle: (math.pi), 
                    arcSweep: math.pi, // half-circle sweep
                  ),
                  behavior: const CreativeUIArcProgressBehavior(
                    value: 0, maxValue: 0, indeterminate: true,
                  ),
                  animation: const CreativeUIArcProgressAnimation(
                    indeterminateRotationDuration: Duration(milliseconds: 900),
                    indeterminateSweepFraction: 0.4, // 40% of arcSweep
                    indeterminateMotion: IndeterminateMotion.ltr, // ⬅️
                    indeterminateSpeedCps: 2.0, // 2 cycles per second
                  ),
                ),
              )
            ],
          ),
        ),
        Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text("CONTROLLABLE", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            CreativeUIArcProgress(
                controller: arcCtrl,
                options: CreativeUIArcProgressOptions(
                  styles: const CreativeUIArcProgressStyles(
                    size: 80,
                    strokeWidth: 12,
                    progressColor: Colors.blue,
                    startAngle: (math.pi),
                    arcSweep: math.pi,
                  ),
                  behavior: const CreativeUIArcProgressBehavior(
                    value: 30,
                    maxValue: 100,
                    loopEnabled: true,
                    playOnInit: true,
                  ),
                  callbacks: CreativeUIArcProgressCallbacks(
                    onCompletedInterval: () => debugPrint('Full arc completed!'),
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                arcCtrl.play(
                value: 65,
                max: 100,
              );
              },
              child: const Text('Increase Progress'),
            ),
            ],
          ),
        ),
        Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text("PING-PONG", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            CreativeUIArcProgress(
              options: CreativeUIArcProgressOptions(
                styles: const CreativeUIArcProgressStyles(
                  size: 72,
                  arcSweep: math.pi * 1.25,
                  progressColor: Colors.indigo,
                ),
                behavior: const CreativeUIArcProgressBehavior(value: 0, maxValue: 0, indeterminate: true),
                animation: const CreativeUIArcProgressAnimation(
                  indeterminateMotion: IndeterminateMotion.pingPong, // default
                  indeterminateRotationDuration: Duration(milliseconds: 1000),
                  indeterminateSweepFraction: 0.4,
                ),
              ),
            ),
            ],
          ),
        ),
        ],
      ),
      ),
    );
  }
  

}

