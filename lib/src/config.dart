import 'dart:math';

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
  final ColorMode? colorMode;

  const Config({this.colorMode});

  static void throwNullError(String colorModeStr, String configStr) {
    throw FlutterError(
        'When using `ColorMode.$colorModeStr`, `$configStr` must be set.');
  }

  static int _resolveLayerCount(
    String configName, {
    int? layers,
    List<Object?>? colors,
    List<Object?>? gradients,
    List<Object?>? durations,
    List<Object?>? heightPercentages,
    List<Object?>? opacityPercentages,
  }) {
    final lengths = <String, int>{};
    if (layers != null) {
      if (layers <= 0) {
        throw FlutterError('`layers` must be greater than zero.');
      }
      lengths['layers'] = layers;
    }
    if (colors != null) lengths['colors'] = colors.length;
    if (gradients != null) lengths['gradients'] = gradients.length;
    if (durations != null) lengths['durations'] = durations.length;
    if (heightPercentages != null) {
      lengths['heightPercentages'] = heightPercentages.length;
    }
    if (opacityPercentages != null) {
      lengths['opacityPercentages'] = opacityPercentages.length;
    }

    if (lengths.isEmpty) return 3;

    final expected = lengths.values.first;
    if (expected == 0) {
      throw FlutterError('`$configName` must define at least one layer.');
    }
    for (final entry in lengths.entries) {
      if (entry.value != expected) {
        throw FlutterError(
          'Length of ${lengths.keys.map((name) => '`$name`').join(', ')} '
          'must be equal.',
        );
      }
    }

    return expected;
  }

  static List<int> _durationsOrDefault(List<int>? values, int layers) {
    final durations = values ??
        List<int>.generate(
          layers,
          (index) => 5000 + (layers - index) * 2000,
        );
    _validateDurations(durations);
    return List<int>.unmodifiable(durations);
  }

  static void _validateDurations(List<int> durations) {
    if (durations.isEmpty) {
      throw FlutterError('`durations` must define at least one layer.');
    }
    for (final duration in durations) {
      if (duration <= 0) {
        throw FlutterError('Every value in `durations` must be positive.');
      }
    }
  }

  static List<double> _heightPercentagesOrDefault(
    List<double>? values,
    int layers,
  ) {
    final heightPercentages = values ??
        List<double>.generate(
          layers,
          (index) => min(0.9, 0.2 + index * 0.03),
        );
    _validateHeightPercentages(heightPercentages);
    return List<double>.unmodifiable(heightPercentages);
  }

  static void _validateHeightPercentages(List<double> heightPercentages) {
    if (heightPercentages.isEmpty) {
      throw FlutterError('`heightPercentages` must define at least one layer.');
    }
    for (final heightPercentage in heightPercentages) {
      if (heightPercentage < 0 || heightPercentage > 1) {
        throw FlutterError(
          'Every value in `heightPercentages` must be between 0 and 1.',
        );
      }
    }
  }

  static List<double> _opacityPercentagesOrDefault(
    List<double>? values,
    int layers,
  ) {
    final opacityPercentages = values ??
        List<double>.generate(
          layers,
          (index) => layers == 1 ? 0.35 : 0.45 - (0.25 * index / (layers - 1)),
        );
    _validateOpacityPercentages(opacityPercentages);
    return List<double>.unmodifiable(opacityPercentages);
  }

  static void _validateOpacityPercentages(List<double> opacityPercentages) {
    if (opacityPercentages.isEmpty) {
      throw FlutterError(
          '`opacityPercentages` must define at least one layer.');
    }
    for (final opacityPercentage in opacityPercentages) {
      if (opacityPercentage < 0 || opacityPercentage > 1) {
        throw FlutterError(
          'Every value in `opacityPercentages` must be between 0 and 1.',
        );
      }
    }
  }
}

class CustomConfig extends Config {
  final List<Color>? colors;
  final List<List<Color>>? gradients;
  final Alignment? gradientBegin;
  final Alignment? gradientEnd;
  final List<int>? durations;
  final List<double>? heightPercentages;
  final MaskFilter? blur;

  CustomConfig({
    List<Color>? colors,
    List<List<Color>>? gradients,
    this.gradientBegin,
    this.gradientEnd,
    required List<int>? durations,
    required List<double>? heightPercentages,
    this.blur,
  })  : colors = colors,
        gradients = gradients,
        durations = durations,
        heightPercentages = heightPercentages,
        super(colorMode: ColorMode.custom) {
    if (colors == null && gradients == null) {
      Config.throwNullError('custom', 'colors` or `gradients');
    }
    if (colors != null && gradients != null) {
      throw FlutterError('Cannot provide both `colors` and `gradients`.');
    }
    if (durations == null) {
      Config.throwNullError('custom', 'durations');
    }
    if (heightPercentages == null) {
      Config.throwNullError('custom', 'heightPercentages');
    }
    final resolvedDurations = durations!;
    final resolvedHeightPercentages = heightPercentages!;
    Config._resolveLayerCount(
      'CustomConfig',
      colors: colors,
      gradients: gradients,
      durations: resolvedDurations,
      heightPercentages: resolvedHeightPercentages,
    );
    Config._validateDurations(resolvedDurations);
    Config._validateHeightPercentages(resolvedHeightPercentages);
    if (gradients == null && (gradientBegin != null || gradientEnd != null)) {
      throw FlutterError(
          'You set a gradient direction but forgot setting `gradients`.');
    }
    if (colors != null && colors.isEmpty) {
      throw FlutterError('`colors` must define at least one layer.');
    }
    if (gradients != null) {
      for (final gradient in gradients) {
        if (gradient.length < 2) {
          throw FlutterError(
              'Every gradient in `gradients` must have at least two colors.');
        }
      }
    }
  }
}

class RandomConfig extends Config {
  final List<Color> colors;
  final List<int> durations;
  final List<double> heightPercentages;
  final MaskFilter? blur;

  RandomConfig({
    int? layers,
    int? seed,
    List<Color>? colors,
    List<int>? durations,
    List<double>? heightPercentages,
    this.blur,
  })  : colors = colors == null
            ? _buildRandomColors(
                Config._resolveLayerCount(
                  'RandomConfig',
                  layers: layers,
                  durations: durations,
                  heightPercentages: heightPercentages,
                ),
                seed,
              )
            : List<Color>.unmodifiable(colors),
        durations = Config._durationsOrDefault(
          durations,
          Config._resolveLayerCount(
            'RandomConfig',
            layers: layers,
            colors: colors,
            durations: durations,
            heightPercentages: heightPercentages,
          ),
        ),
        heightPercentages = Config._heightPercentagesOrDefault(
          heightPercentages,
          Config._resolveLayerCount(
            'RandomConfig',
            layers: layers,
            colors: colors,
            durations: durations,
            heightPercentages: heightPercentages,
          ),
        ),
        super(colorMode: ColorMode.random) {
    if (this.colors.isEmpty) {
      throw FlutterError('`colors` must define at least one layer.');
    }
  }

  static List<Color> _buildRandomColors(int layers, int? seed) {
    final random = seed == null ? Random() : Random(seed);
    return List<Color>.unmodifiable(
      List<Color>.generate(layers, (index) {
        final hue = random.nextDouble() * 360;
        final saturation = 0.55 + random.nextDouble() * 0.35;
        final value = 0.65 + random.nextDouble() * 0.25;
        final alpha = 0.22 + random.nextDouble() * 0.38;
        return HSVColor.fromAHSV(alpha, hue, saturation, value).toColor();
      }),
    );
  }
}

class SingleConfig extends Config {
  final Color color;
  final List<double> opacityPercentages;
  final List<int> durations;
  final List<double> heightPercentages;
  final MaskFilter? blur;

  SingleConfig({
    int? layers,
    this.color = const Color(0xFF2196F3),
    List<double>? opacityPercentages,
    List<int>? durations,
    List<double>? heightPercentages,
    this.blur,
  })  : opacityPercentages = Config._opacityPercentagesOrDefault(
          opacityPercentages,
          Config._resolveLayerCount(
            'SingleConfig',
            layers: layers,
            durations: durations,
            heightPercentages: heightPercentages,
            opacityPercentages: opacityPercentages,
          ),
        ),
        durations = Config._durationsOrDefault(
          durations,
          Config._resolveLayerCount(
            'SingleConfig',
            layers: layers,
            durations: durations,
            heightPercentages: heightPercentages,
            opacityPercentages: opacityPercentages,
          ),
        ),
        heightPercentages = Config._heightPercentagesOrDefault(
          heightPercentages,
          Config._resolveLayerCount(
            'SingleConfig',
            layers: layers,
            durations: durations,
            heightPercentages: heightPercentages,
            opacityPercentages: opacityPercentages,
          ),
        ),
        super(colorMode: ColorMode.single);
}
