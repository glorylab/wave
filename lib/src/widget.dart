// SPDX-License-Identifier: MIT AND Apache-2.0
//
// This implementation includes code adapted from WaveView_flutter.
// See NOTICE and LICENSE-APACHE-2.0 for third-party attribution details.

import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

import 'config.dart';

/// Paints animated wave layers with the supplied [config].
class WaveWidget extends StatefulWidget {
  /// Color, duration, height, and blur configuration for each wave layer.
  final Config config;

  /// Fixed paint size for each wave layer.
  final Size size;

  /// Base vertical amplitude of the wave path.
  final double waveAmplitude;

  /// Initial phase offset for the wave path.
  final double wavePhase;

  /// Horizontal frequency of the wave path.
  final double waveFrequency;

  /// Legacy vertical offset retained for source compatibility.
  ///
  /// Built-in configs provide per-layer `heightPercentages`, so new code should
  /// set heights on [SingleConfig], [RandomConfig], or [CustomConfig] instead.
  @Deprecated(
    'Use heightPercentages on SingleConfig, RandomConfig, or CustomConfig.',
  )
  final double heightPercentage;

  /// Total animation duration in milliseconds when [isLoop] is false.
  final int? duration;

  /// Background color behind the animated waves.
  final Color? backgroundColor;

  /// Background image behind the animated waves.
  final DecorationImage? backgroundImage;

  /// Whether wave animations repeat indefinitely.
  final bool isLoop;

  /// Creates an animated wave widget.
  WaveWidget({
    required this.config,
    required this.size,
    this.waveAmplitude = 20.0,
    this.wavePhase = 10.0,
    this.waveFrequency = 1.6,
    @Deprecated(
      'Use heightPercentages on SingleConfig, RandomConfig, or CustomConfig.',
    )
        this.heightPercentage = 0.2,
    this.duration = 6000,
    this.backgroundColor,
    this.backgroundImage,
    this.isLoop = true,
  });

  @override
  State<StatefulWidget> createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget> with TickerProviderStateMixin {
  List<_WaveLayerAnimation> _layers = <_WaveLayerAnimation>[];
  Timer? _endAnimationTimer;

  void _initAnimations() {
    final specs = _buildLayerSpecs(widget.config);
    _layers = specs.map((spec) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: spec.duration),
      );
      final curve = CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      );
      final phaseValue = Tween<double>(
        begin: widget.wavePhase,
        end: 360 + widget.wavePhase,
      ).animate(curve);

      controller.repeat(reverse: true);
      return _WaveLayerAnimation(
        controller: controller,
        phaseValue: phaseValue,
      );
    }).toList(growable: false);

    if (!widget.isLoop) {
      _endAnimationTimer = Timer(
        Duration(milliseconds: widget.duration ?? 6000),
        _stopAnimations,
      );
    }
  }

  List<_WaveLayerSpec> _buildLayerSpecs(Config config) {
    if (config.colorMode == ColorMode.custom) {
      final customConfig = config as CustomConfig;
      return List<_WaveLayerSpec>.generate(
        customConfig.durations!.length,
        (index) => _WaveLayerSpec(
          color:
              customConfig.colors == null ? null : customConfig.colors![index],
          gradient: customConfig.gradients == null
              ? null
              : customConfig.gradients![index],
          gradientBegin: customConfig.gradientBegin,
          gradientEnd: customConfig.gradientEnd,
          duration: customConfig.durations![index],
          heightPercentage: customConfig.heightPercentages![index],
          amplitude: widget.waveAmplitude + 10,
          blur: customConfig.blur,
        ),
        growable: false,
      );
    }
    if (config.colorMode == ColorMode.random) {
      final randomConfig = config as RandomConfig;
      return List<_WaveLayerSpec>.generate(
        randomConfig.durations.length,
        (index) => _WaveLayerSpec(
          color: randomConfig.colors[index],
          duration: randomConfig.durations[index],
          heightPercentage: randomConfig.heightPercentages[index],
          amplitude: _amplitudeForLayer(index),
          blur: randomConfig.blur,
        ),
        growable: false,
      );
    }
    if (config.colorMode == ColorMode.single) {
      final singleConfig = config as SingleConfig;
      return List<_WaveLayerSpec>.generate(
        singleConfig.durations.length,
        (index) => _WaveLayerSpec(
          color: _colorWithOpacity(
            singleConfig.color,
            singleConfig.opacityPercentages[index],
          ),
          duration: singleConfig.durations[index],
          heightPercentage: singleConfig.heightPercentages[index],
          amplitude: _amplitudeForLayer(index),
          blur: singleConfig.blur,
        ),
        growable: false,
      );
    }

    throw FlutterError('Unsupported or missing `ColorMode` in `config`.');
  }

  List<int> _animationDurations(Config config) {
    if (config.colorMode == ColorMode.custom) {
      return (config as CustomConfig).durations!;
    }
    if (config.colorMode == ColorMode.random) {
      return (config as RandomConfig).durations;
    }
    if (config.colorMode == ColorMode.single) {
      return (config as SingleConfig).durations;
    }

    throw FlutterError('Unsupported or missing `ColorMode` in `config`.');
  }

  Color _colorWithOpacity(Color color, double opacity) {
    return color.withAlpha((opacity * 255).round());
  }

  double _amplitudeForLayer(int index) {
    return widget.waveAmplitude + 8 + index * 2;
  }

  List<Widget> _buildPaints() {
    final specs = _buildLayerSpecs(widget.config);
    return _layers.asMap().entries.map((entry) {
      final layer = entry.value;
      final spec = specs[entry.key];
      return CustomPaint(
        painter: _CustomWavePainter(
          color: spec.color,
          gradient: spec.gradient,
          gradientBegin: spec.gradientBegin,
          gradientEnd: spec.gradientEnd,
          heightPercentage: spec.heightPercentage,
          repaint: layer.controller,
          waveFrequency: widget.waveFrequency,
          wavePhaseValue: layer.phaseValue,
          waveAmplitude: spec.amplitude,
          blur: spec.blur,
        ),
        size: widget.size,
      );
    }).toList(growable: false);
  }

  void _stopAnimations() {
    for (final layer in _layers) {
      layer.controller.stop();
    }
  }

  void _disposeAnimations() {
    _endAnimationTimer?.cancel();
    _endAnimationTimer = null;
    for (final layer in _layers) {
      layer.controller.dispose();
    }
    _layers = <_WaveLayerAnimation>[];
  }

  bool _shouldRecreateAnimations(WaveWidget oldWidget) {
    if (oldWidget.wavePhase != widget.wavePhase ||
        oldWidget.isLoop != widget.isLoop ||
        oldWidget.duration != widget.duration) {
      return true;
    }

    final oldDurations = _animationDurations(oldWidget.config);
    final durations = _animationDurations(widget.config);
    return !_listEquals(oldDurations, durations);
  }

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  @override
  void didUpdateWidget(WaveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldRecreateAnimations(oldWidget)) {
      _disposeAnimations();
      _initAnimations();
    }
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          image: widget.backgroundImage,
        ),
        child: Stack(
          children: _buildPaints(),
        ),
      ),
    );
  }

  bool _listEquals<T>(List<T> first, List<T> second) {
    if (first.length != second.length) return false;
    for (int i = 0; i < first.length; i++) {
      if (first[i] != second[i]) return false;
    }
    return true;
  }
}

class _WaveLayerSpec {
  final Color? color;
  final List<Color>? gradient;
  final Alignment? gradientBegin;
  final Alignment? gradientEnd;
  final int duration;
  final double heightPercentage;
  final double amplitude;
  final MaskFilter? blur;

  const _WaveLayerSpec({
    this.color,
    this.gradient,
    this.gradientBegin,
    this.gradientEnd,
    required this.duration,
    required this.heightPercentage,
    required this.amplitude,
    this.blur,
  });
}

class _WaveLayerAnimation {
  final AnimationController controller;
  final Animation<double> phaseValue;

  const _WaveLayerAnimation({
    required this.controller,
    required this.phaseValue,
  });
}

/// Legacy metadata object for a painted wave layer.
///
/// This class is no longer used by the painter and remains exported only for
/// source compatibility with older code.
@Deprecated(
  'Layer is an internal implementation detail and may be removed in a future '
  'major release.',
)
class Layer {
  /// Solid color for the layer.
  final Color? color;

  /// Gradient colors for the layer.
  final List<Color>? gradient;

  /// Optional blur mask for the layer.
  final MaskFilter? blur;

  /// Cached path for the layer.
  final Path? path;

  /// Vertical amplitude for the layer.
  final double? amplitude;

  /// Animation phase for the layer.
  final double? phase;

  /// Creates legacy layer metadata.
  Layer({
    this.color,
    this.gradient,
    this.blur,
    this.path,
    this.amplitude,
    this.phase,
  });
}

class _CustomWavePainter extends CustomPainter {
  static const int _minWaveSamples = 96;
  static const int _samplesPerFrequencyUnit = 48;
  static const double _targetWaveSampleWidth = 4.0;

  final Color? color;
  final List<Color>? gradient;
  final Alignment? gradientBegin;
  final Alignment? gradientEnd;
  final MaskFilter? blur;
  final double waveAmplitude;
  final Animation<double> wavePhaseValue;
  final double waveFrequency;
  final double heightPercentage;

  final Paint _paint = Paint();
  final Path _path = Path();
  Shader? _cachedGradientShader;
  Size? _cachedGradientSize;
  double? _cachedGradientCenterY;

  _CustomWavePainter({
    this.color,
    this.gradient,
    this.gradientBegin,
    this.gradientEnd,
    this.blur,
    required this.heightPercentage,
    required this.waveFrequency,
    required this.wavePhaseValue,
    required this.waveAmplitude,
    Listenable? repaint,
  }) : super(repaint: repaint);

  void _paintWave(double viewCenterY, Size size, Canvas canvas) {
    final amplitude = -0.8 * waveAmplitude;
    final phase = wavePhaseValue.value * 2 + 30;
    final path = _path..reset();
    path.moveTo(
      0.0,
      viewCenterY + amplitude * _getSinY(phase, -1, size),
    );

    final sampleCount = _sampleCountForWidth(size.width);
    final sampleWidth = size.width / sampleCount;
    for (int i = 1; i <= sampleCount; i++) {
      final x = i == sampleCount ? size.width : sampleWidth * i;
      path.lineTo(
        x,
        viewCenterY + amplitude * _getSinY(phase, x, size),
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();

    if (color != null) {
      _paint.color = color!;
      _paint.shader = null;
    } else if (gradient != null) {
      _paint.shader = _gradientShader(size, viewCenterY);
    }
    _paint.maskFilter = blur;
    _paint.style = PaintingStyle.fill;
    canvas.drawPath(path, _paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }
    final viewCenterY = size.height * (heightPercentage + 0.1);
    _paintWave(viewCenterY, size, canvas);
  }

  @override
  bool shouldRepaint(covariant _CustomWavePainter oldDelegate) {
    return oldDelegate.color != color ||
        !_listEquals(oldDelegate.gradient, gradient) ||
        oldDelegate.gradientBegin != gradientBegin ||
        oldDelegate.gradientEnd != gradientEnd ||
        oldDelegate.blur != blur ||
        oldDelegate.waveAmplitude != waveAmplitude ||
        oldDelegate.wavePhaseValue != wavePhaseValue ||
        oldDelegate.waveFrequency != waveFrequency ||
        oldDelegate.heightPercentage != heightPercentage;
  }

  double _getSinY(
    double startRadius,
    double currentPosition,
    Size size,
  ) {
    final scale = pi / size.width;
    final phaseScale = 2 * pi / 360.0;

    return sin(
      scale * waveFrequency * (currentPosition + 1) + startRadius * phaseScale,
    );
  }

  int _sampleCountForWidth(double width) {
    final maxSamples = max(1, width.ceil());
    final widthSamples = (width / _targetWaveSampleWidth).ceil();
    final frequencySamples =
        (waveFrequency.abs() * _samplesPerFrequencyUnit).ceil();
    final requestedSamples =
        max(_minWaveSamples, max(widthSamples, frequencySamples));
    return min(maxSamples, requestedSamples);
  }

  Shader _gradientShader(Size size, double viewCenterY) {
    if (_cachedGradientShader != null &&
        _cachedGradientSize == size &&
        _cachedGradientCenterY == viewCenterY) {
      return _cachedGradientShader!;
    }

    final shaderHeight = max(0.0, size.height - viewCenterY * heightPercentage);
    final rect = Offset.zero & Size(size.width, shaderHeight);
    _cachedGradientShader = LinearGradient(
      begin: gradientBegin ?? Alignment.bottomCenter,
      end: gradientEnd ?? Alignment.topCenter,
      colors: gradient!,
    ).createShader(rect);
    _cachedGradientSize = size;
    _cachedGradientCenterY = viewCenterY;
    return _cachedGradientShader!;
  }

  bool _listEquals<T>(List<T>? first, List<T>? second) {
    if (first == null) return second == null;
    if (second == null || first.length != second.length) return false;
    for (int i = 0; i < first.length; i++) {
      if (first[i] != second[i]) return false;
    }
    return true;
  }
}
