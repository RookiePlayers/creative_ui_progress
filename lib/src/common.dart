enum IndeterminateMotion {
  pingPong, // back-and-forth
  ltr, // left to right along the track
  rtl, // right to left along the track
}

enum ProgressDirection { ltr, rtl }

enum ShimmerMode {
  never, // do not run
  once, // run exactly once
  count, // run N cycles (see shimmerCount)
  periodic, // run, pause, run, ... (see shimmerPause)
  continuous, // run forever
}
