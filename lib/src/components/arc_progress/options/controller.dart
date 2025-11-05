import 'package:flutter/foundation.dart';

class CreativeUIArcProgressController {
  void Function({double? percentage, double? value, double? max}) play =
      ({double? percentage, double? value, double? max}) {};
  VoidCallback pause = () {};
  VoidCallback resume = () {};
  void Function({double? toPercentage}) reverse = ({double? toPercentage}) {};
}