import 'dart:ui';

import 'package:flutter/widgets.dart';

enum ColorMode {
  /// Waves with *single* **color** but different **alpha** and **amplitude**.
  single,

  /// Waves using *random* **color**, **alpha** and **amplitude**.
  random,

  /// Waves' colors must be set, and [colors]'s length must equal with [layers]
  custom,
}

abstract class Config {
  final ColorMode colorMode;

  Config({this.colorMode});

  void throwNullError(String colorModeStr, String configStr) {
    throw FlutterError(
        'When using `ColorMode.$colorModeStr`, `$configStr` must be set.');
  }
}

class CustomConfig extends Config {
  final List<Color> colors;
  final List<List<Color>> gradients;
  final Alignment gradientBegin;
  final Alignment gradientEnd;
  final List<int> durations;
  final List<double> heightPercentages;
  final MaskFilter blur;

  CustomConfig({
    this.colors,
    this.gradients,
    this.gradientBegin,
    this.gradientEnd,
    @required this.durations,
    @required this.heightPercentages,
    this.blur,
  })  : assert(() {
          if (colors == null && gradients == null) {
            throwNullError('custom', 'colors` or `gradients');
          }
          return true;
        }()),
        assert(() {
          if (gradients == null &&
              (gradientBegin != null || gradientEnd != null)) {
            throw FlutterError(
                'You set a gradient direction but forgot setting `gradients`.');
          }
          return true;
        }()),
        assert(() {
          if (durations == null) {
            throwNullError('custom', 'durations');
          }
          return true;
        }()),
        assert(() {
          if (heightPercentages == null) {
            throwNullError('custom', 'heightPercentages');
          }
          return true;
        }()),
        assert(() {
          if (colors != null) {
            if (colors.length != durations.length ||
                colors.length != heightPercentages.length) {
              throw FlutterError(
                  'Length of `colors`, `durations` and `heightPercentages` must be equal.');
            }
          }
          return true;
        }()),
        assert(colors == null || gradients == null,
            'Cannot provide both colors and gradients.'),
        super(colorMode: ColorMode.custom);
}

/// todo
class RandomConfig extends Config {
  RandomConfig() : super(colorMode: ColorMode.random);
}

/// todo
class SingleConfig extends Config {
  SingleConfig() : super(colorMode: ColorMode.single);
}
