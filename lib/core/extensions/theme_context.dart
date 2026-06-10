import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;

  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  EdgeInsets get padding => MediaQuery.paddingOf(this);
  double get viewInsetsBottom => MediaQuery.viewInsetsOf(this).bottom;
}
