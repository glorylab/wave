import 'dart:math';

import 'package:flutter/widgets.dart';

/// Selects how wave layer colors are generated.
enum ColorMode {
  /// Uses one base color with per-layer opacity and amplitude values.
  single,

  /// Generates random colors for each layer.
  random,

  /// Uses explicit colors or gradients supplied by [CustomConfig].
  custom,
}

/// Base class for wave color and layer configuration.
abstract class Config {
  /// The color generation mode represented by this config.
  final ColorMode? colorMode;

  /// Creates a wave configuration with the selected [colorMode].
  const Config({this.colorMode});

  /// Throws a consistent error for missing required config values.
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

/// Configuration for waves with explicit per-layer colors or gradients.
class CustomConfig extends Config {
  /// Per-layer solid colors.
  final List<Color>? colors;

  /// Per-layer gradients.
  final List<List<Color>>? gradients;

  /// Alignment where each gradient begins.
  final Alignment? gradientBegin;

  /// Alignment where each gradient ends.
  final Alignment? gradientEnd;

  /// Per-layer animation durations in milliseconds.
  final List<int>? durations;

  /// Per-layer vertical offsets, expressed as fractions from 0 to 1.
  final List<double>? heightPercentages;

  /// Optional blur mask applied to each wave layer.
  final MaskFilter? blur;

  /// Creates explicit wave layers from [colors] or [gradients].
  ///
  /// Provide exactly one of [colors] or [gradients]. The configured layer
  /// lists must have equal lengths, and each gradient must contain at least
  /// two colors.
  CustomConfig({
    List<Color>? colors,
    List<List<Color>>? gradients,
    this.gradientBegin,
    this.gradientEnd,
    required List<int>? durations,
    required List<double>? heightPercentages,
    this.blur,
  })  : colors = colors == null ? null : List<Color>.unmodifiable(colors),
        gradients = gradients == null
            ? null
            : List<List<Color>>.unmodifiable(
                gradients.map<List<Color>>(
                  (gradient) => List<Color>.unmodifiable(gradient),
                ),
              ),
        durations =
            durations == null ? null : List<int>.unmodifiable(durations),
        heightPercentages = heightPercentages == null
            ? null
            : List<double>.unmodifiable(heightPercentages),
        super(colorMode: ColorMode.custom) {
    if (this.colors == null && this.gradients == null) {
      Config.throwNullError('custom', 'colors` or `gradients');
    }
    if (this.colors != null && this.gradients != null) {
      throw FlutterError('Cannot provide both `colors` and `gradients`.');
    }
    if (this.durations == null) {
      Config.throwNullError('custom', 'durations');
    }
    if (this.heightPercentages == null) {
      Config.throwNullError('custom', 'heightPercentages');
    }
    final resolvedDurations = this.durations!;
    final resolvedHeightPercentages = this.heightPercentages!;
    Config._resolveLayerCount(
      'CustomConfig',
      colors: this.colors,
      gradients: this.gradients,
      durations: resolvedDurations,
      heightPercentages: resolvedHeightPercentages,
    );
    Config._validateDurations(resolvedDurations);
    Config._validateHeightPercentages(resolvedHeightPercentages);
    if (this.gradients == null &&
        (gradientBegin != null || gradientEnd != null)) {
      throw FlutterError(
          'You set a gradient direction but forgot setting `gradients`.');
    }
    if (this.colors != null && this.colors!.isEmpty) {
      throw FlutterError('`colors` must define at least one layer.');
    }
    if (this.gradients != null) {
      for (final gradient in this.gradients!) {
        if (gradient.length < 2) {
          throw FlutterError(
              'Every gradient in `gradients` must have at least two colors.');
        }
      }
    }
  }
}

/// Configuration for waves with generated random colors.
class RandomConfig extends Config {
  /// Generated or supplied per-layer colors.
  final List<Color> colors;

  /// Per-layer animation durations in milliseconds.
  final List<int> durations;

  /// Per-layer vertical offsets, expressed as fractions from 0 to 1.
  final List<double> heightPercentages;

  /// Optional blur mask applied to each wave layer.
  final MaskFilter? blur;

  /// Creates randomly colored wave layers.
  ///
  /// Use [layers] to control the number of generated layers and [seed] for
  /// deterministic color generation. Any supplied lists must have equal
  /// lengths.
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

/// Configuration for waves derived from one base color.
class SingleConfig extends Config {
  /// Base color used for every wave layer.
  final Color color;

  /// Per-layer opacity values from 0 to 1.
  final List<double> opacityPercentages;

  /// Per-layer animation durations in milliseconds.
  final List<int> durations;

  /// Per-layer vertical offsets, expressed as fractions from 0 to 1.
  final List<double> heightPercentages;

  /// Optional blur mask applied to each wave layer.
  final MaskFilter? blur;

  /// Creates wave layers from a single [color].
  ///
  /// Use [layers] to control generated default list lengths. Any supplied
  /// lists must have equal lengths.
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
