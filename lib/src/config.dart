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

    bool gradientsAreEqual = true;
    bool heightsAreEqual = true;

    if (other is CustomConfig) {
      print('colors: ${listEquals(other.colors, colors)}');

      if (other.gradients?.length != gradients?.length) {
        gradientsAreEqual = false;
      } else {
        if (other.gradients != null && gradients != null) {
          for (int i = 0; i < gradients!.length; i++) {
            final l1 = other.gradients![i];
            final l2 = gradients![i];
            print('l1: $l1');
            if (!listEquals(l1, l2)) {
              gradientsAreEqual = false;
              break;
            }
          }
        }
      }

      if (other.heightPercentages?.length != heightPercentages?.length) {
        heightsAreEqual = false;
      } else {
        if (other.heightPercentages != null && heightPercentages != null) {
          for (int i = 0; i < heightPercentages!.length; i++) {
            final l1 = other.heightPercentages![i];
            final l2 = heightPercentages![i];

            final diff = (l1 - l2).abs();
            if (l1 != l2 && diff > 0.001) {
              heightsAreEqual = false;
              break;
            }
          }
        }
      }

      if (!gradientsAreEqual) {
        print('Gradients are equal: $gradientsAreEqual');
      }
      if (!heightsAreEqual) {
        print('Heights are equal: $heightsAreEqual');
      }
    }

    return other is CustomConfig &&
        listEquals(other.colors, colors) &&
        gradientsAreEqual &&
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
