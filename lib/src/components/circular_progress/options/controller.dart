import 'package:flutter/foundation.dart';

class CreativeUICircularProgressController {
  void Function({double? percentage, double? value, double? max}) play =
      ({double? percentage, double? value, double? max}) {};
  VoidCallback pause = () {};
  VoidCallback resume = () {};
  void Function({double? toPercentage}) reverse = ({double? toPercentage}) {};
}
