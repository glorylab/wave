import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wave/flutter_wave.dart';

enum ColorMode {
  /// Waves with *single* **color** but different **alpha** and **amplitude**.
  single,

  /// Waves using *random* **color**, **alpha** and **amplitude**.
  random,

  /// Waves' colors must be set, and [colors]'s length must equal with [layers]
  custom,
}

abstract class Config {
  final ColorMode? colorMode;

  Config({
    this.colorMode,
  });

  @override
  String toString() => 'Config(colorMode: $colorMode)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Config && other.colorMode == colorMode;
  }

  @override
  int get hashCode => colorMode.hashCode;
}

class CustomConfig extends Config {
  final List<Color>? colors;
  final List<List<Color>>? gradients;
  final Alignment? gradientBegin;
  final Alignment? gradientEnd;
  final List<int>? durations;
  final List<double>? heightPercentages;
  final MaskFilter? blur;
  final List<StrokeData?>? enabledStrokes;

  CustomConfig({
    this.colors,
    this.gradients,
    this.gradientBegin,
    this.gradientEnd,
    required this.durations,
    required this.heightPercentages,
    this.blur,
    this.enabledStrokes,
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
              'You set a gradient direction but forgot setting `gradients`.',
            );
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
          if (colors != null &&
              durations != null &&
              heightPercentages != null) {
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
        assert(
          enabledStrokes == null ||
              enabledStrokes.length == colors?.length ||
              enabledStrokes.length == gradients?.length,
          'Length of `enabledStrokes` must be equal to length of `colors` or `gradients`.',
        ),
        super(colorMode: ColorMode.custom);

  static void throwNullError(String colorModeStr, String configStr) {
    throw FlutterError(
        'When using `ColorMode.$colorModeStr`, `$configStr` must be set.');
  }

  CustomConfig copyWith({
    List<Color>? colors,
    List<List<Color>>? gradients,
    Alignment? gradientBegin,
    Alignment? gradientEnd,
    List<int>? durations,
    List<double>? heightPercentages,
    MaskFilter? blur,
    List<StrokeData?>? enabledStrokes,
  }) {
    return CustomConfig(
      colors: colors ?? this.colors,
      gradients: gradients ?? this.gradients,
      gradientBegin: gradientBegin ?? this.gradientBegin,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      durations: durations ?? this.durations,
      heightPercentages: heightPercentages ?? this.heightPercentages,
      blur: blur ?? this.blur,
      enabledStrokes: enabledStrokes ?? this.enabledStrokes,
    );
  }

  @override
  String toString() {
    return 'CustomConfig(colors: $colors, gradients: $gradients, gradientBegin: $gradientBegin, gradientEnd: $gradientEnd, durations: $durations, heightPercentages: $heightPercentages, blur: $blur, enabledStrokes: $enabledStrokes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is CustomConfig) {
      print('colors: ${listEquals(other.colors, colors)}');
      print('gradients: ${listEquals(other.gradients, gradients)}');
      print('gradientBegin: ${other.gradientBegin == gradientBegin}');
      print('gradientEnd: ${other.gradientEnd == gradientEnd}');
      print('durations: ${listEquals(other.durations, durations)}');
      print(
          'heightPercentages: ${listEquals(other.heightPercentages, heightPercentages)}');
      print('blur: ${other.blur == blur}');
      print(
          'enabledStrokes: ${listEquals(other.enabledStrokes, enabledStrokes)}');
    }

    return other is CustomConfig &&
        listEquals(other.colors, colors) &&
        listEquals(other.gradients, gradients) &&
        other.gradientBegin == gradientBegin &&
        other.gradientEnd == gradientEnd &&
        listEquals(other.durations, durations) &&
        listEquals(other.heightPercentages, heightPercentages) &&
        other.blur == blur &&
        listEquals(other.enabledStrokes, enabledStrokes);
  }

  @override
  int get hashCode {
    return colors.hashCode ^
        gradients.hashCode ^
        gradientBegin.hashCode ^
        gradientEnd.hashCode ^
        durations.hashCode ^
        heightPercentages.hashCode ^
        blur.hashCode ^
        enabledStrokes.hashCode;
  }
}

class RandomConfig extends Config {
  RandomConfig() : super(colorMode: ColorMode.random);
}

class SingleConfig extends Config {
  SingleConfig() : super(colorMode: ColorMode.single);
}
