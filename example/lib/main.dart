import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wave/wave.dart';

void main() => runApp(const WaveGeneratorApp());

const String _appTitle = 'Wave Generator';
const String _logoAsset = 'web/icons/Icon-192.png';
final Uri _repoUri = Uri.parse('https://github.com/glorylab/wave');

enum _ConfigMode { single, random, custom }

const double _layersMin = 1;
const double _layersMax = 5;
const double _heightMin = 0.18;
const double _heightMax = 0.72;
const double _amplitudeMin = 0;
const double _amplitudeMax = 28;
const double _speedMin = 0.6;
const double _speedMax = 1.8;

const _palettes = <_Palette>[
  _Palette(
    name: 'Ocean',
    background: 0xFFECFEFF,
    seed: 7,
    colors: [0xFF0891B2, 0xFF22D3EE, 0xFF38BDF8, 0xFF2563EB],
  ),
  _Palette(
    name: 'Sunset',
    background: 0xFFFFF7ED,
    seed: 12,
    colors: [0xFFF97316, 0xFFFB7185, 0xFFFACC15, 0xFF7C2D12],
  ),
  _Palette(
    name: 'Mint',
    background: 0xFFF0FDFA,
    seed: 21,
    colors: [0xFF0F766E, 0xFF14B8A6, 0xFF5EEAD4, 0xFFCCFBF1],
  ),
  _Palette(
    name: 'Violet',
    background: 0xFFFAF5FF,
    seed: 34,
    colors: [0xFF6D28D9, 0xFF8B5CF6, 0xFFC084FC, 0xFFF0ABFC],
  ),
];

class WaveGeneratorApp extends StatelessWidget {
  const WaveGeneratorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0891B2),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
      ),
      home: const WaveGeneratorHome(),
    );
  }
}

class WaveGeneratorHome extends StatefulWidget {
  const WaveGeneratorHome({Key? key}) : super(key: key);

  @override
  State<WaveGeneratorHome> createState() => _WaveGeneratorHomeState();
}

class _WaveGeneratorHomeState extends State<WaveGeneratorHome> {
  _ConfigMode _mode = _ConfigMode.custom;
  int _paletteIndex = 0;
  int _layers = 3;
  double _height = 0.42;
  double _amplitude = 12;
  double _speed = 1;
  bool _isLoop = true;

  _Palette get _palette => _palettes[_paletteIndex];

  Future<void> _openRepository() async {
    await launchUrl(_repoUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: _generatedCode()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied')),
    );
  }

  Future<void> _showCodeDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return _CodeDialog(
          code: _generatedCode(),
          onCopy: _copyCode,
        );
      },
    );
  }

  void _setMode(_ConfigMode mode) {
    setState(() {
      _mode = mode;
    });
  }

  void _setPaletteIndex(int index) {
    setState(() {
      _paletteIndex = index;
    });
  }

  void _setLayers(double value) {
    setState(() {
      _layers = _clampSliderValue(value, _layersMin, _layersMax).round();
    });
  }

  void _setHeight(double value) {
    setState(() {
      _height = _clampSliderValue(value, _heightMin, _heightMax);
    });
  }

  void _setAmplitude(double value) {
    setState(() {
      _amplitude = _clampSliderValue(value, _amplitudeMin, _amplitudeMax);
    });
  }

  void _setSpeed(double value) {
    setState(() {
      _speed = _clampSliderValue(value, _speedMin, _speedMax);
    });
  }

  void _setLoop(bool value) {
    setState(() {
      _isLoop = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 980;
            if (isDesktop) {
              return _DesktopConsole(state: this);
            }

            return _StackedConsole(state: this);
          },
        ),
      ),
    );
  }

  Config _config() {
    switch (_mode) {
      case _ConfigMode.single:
        return SingleConfig(
          color: Color(_palette.colors.first),
          layers: _layers,
          opacityPercentages: _opacityPercentages(),
          durations: _durations(),
          heightPercentages: _heightPercentages(),
        );
      case _ConfigMode.random:
        return RandomConfig(
          seed: _palette.seed,
          layers: _layers,
          durations: _durations(),
          heightPercentages: _heightPercentages(),
        );
      case _ConfigMode.custom:
        return CustomConfig(
          gradients: _gradients(),
          durations: _durations(),
          heightPercentages: _heightPercentages(),
          gradientBegin: Alignment.bottomLeft,
          gradientEnd: Alignment.topRight,
        );
    }
  }

  List<int> _durations() {
    return List<int>.generate(_layers, (index) {
      final rawDuration = (18000 - index * 2600) / _speed;
      return rawDuration.round().clamp(3200, 30000).toInt();
    }, growable: false);
  }

  List<double> _heightPercentages() {
    return List<double>.generate(_layers, (index) {
      return (_height + index * 0.035).clamp(0.16, 0.92).toDouble();
    }, growable: false);
  }

  List<double> _opacityPercentages() {
    return List<double>.generate(_layers, (index) {
      return (0.42 - index * 0.06).clamp(0.14, 0.48).toDouble();
    }, growable: false);
  }

  List<List<Color>> _gradients() {
    return List<List<Color>>.generate(_layers, (index) {
      return [
        Color(_palette.colors[index % _palette.colors.length]),
        Color(_palette.colors[(index + 1) % _palette.colors.length]),
      ];
    }, growable: false);
  }

  String _generatedCode() {
    final configCode = _configCode();
    final loopLine = _isLoop ? '' : '      isLoop: false,\n';
    final durationLine = _isLoop ? '' : '      duration: 8000,\n';
    return '''
import 'package:flutter/material.dart';
import 'package:wave/wave.dart';

class GeneratedWave extends StatelessWidget {
  const GeneratedWave({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: WaveWidget(
$configCode
        backgroundColor: const ${_colorLiteral(_palette.background)},
        size: const Size(double.infinity, double.infinity),
        waveAmplitude: ${_amplitude.toStringAsFixed(1)},
$durationLine$loopLine      ),
    );
  }
}
''';
  }

  String _configCode() {
    switch (_mode) {
      case _ConfigMode.single:
        return '''
        config: SingleConfig(
          color: const ${_colorLiteral(_palette.colors.first)},
          layers: $_layers,
          opacityPercentages: const ${_doubleListLiteral(_opacityPercentages())},
          durations: const ${_intListLiteral(_durations())},
          heightPercentages: const ${_doubleListLiteral(_heightPercentages())},
        ),''';
      case _ConfigMode.random:
        return '''
        config: RandomConfig(
          seed: ${_palette.seed},
          layers: $_layers,
          durations: const ${_intListLiteral(_durations())},
          heightPercentages: const ${_doubleListLiteral(_heightPercentages())},
        ),''';
      case _ConfigMode.custom:
        return '''
        config: CustomConfig(
          gradients: const ${_gradientListLiteral()},
          durations: const ${_intListLiteral(_durations())},
          heightPercentages: const ${_doubleListLiteral(_heightPercentages())},
          gradientBegin: Alignment.bottomLeft,
          gradientEnd: Alignment.topRight,
        ),''';
    }
  }

  String _gradientListLiteral() {
    final rows = List<String>.generate(_layers, (index) {
      final first = _palette.colors[index % _palette.colors.length];
      final second = _palette.colors[(index + 1) % _palette.colors.length];
      return '[${_colorLiteral(first)}, ${_colorLiteral(second)}]';
    }, growable: false);
    return '[\n            ${rows.join(',\n            ')},\n          ]';
  }

  String _intListLiteral(List<int> values) {
    return '[${values.join(', ')}]';
  }

  String _doubleListLiteral(List<double> values) {
    return '[${values.map((value) => value.toStringAsFixed(2)).join(', ')}]';
  }

  String _colorLiteral(int value) {
    return 'Color(0x${value.toRadixString(16).padLeft(8, '0').toUpperCase()})';
  }
}

class _DesktopConsole extends StatelessWidget {
  const _DesktopConsole({Key? key, required this.state}) : super(key: key);

  final _WaveGeneratorHomeState state;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF3F6FA),
      child: Column(
        children: [
          _ConsoleTopBar(state: state),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _PreviewPanel(
                      state: state,
                      fillAvailableSpace: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 360,
                    child: _ControlsPanel(
                      state: state,
                      fillAvailableSpace: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StackedConsole extends StatelessWidget {
  const _StackedConsole({Key? key, required this.state}) : super(key: key);

  final _WaveGeneratorHomeState state;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF3F6FA),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _ConsoleTopBar(state: state),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _PreviewPanel(state: state),
                const SizedBox(height: 16),
                _ControlsPanel(state: state),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsoleTopBar extends StatelessWidget {
  const _ConsoleTopBar({Key? key, required this.state}) : super(key: key);

  final _WaveGeneratorHomeState state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        return Container(
          height: compact ? 72 : 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            border: Border(
              bottom: BorderSide(color: Color(0xFFDDE5EF)),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  _logoAsset,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      _appTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_modeLabel(state._mode)} / ${_presetLabel(state)} / ${state._layers} layers',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (!compact) ...[
                _NavbarPerformanceMonitor(
                  compact: constraints.maxWidth < 1160,
                ),
                const SizedBox(width: 12),
              ],
              if (compact) ...[
                IconButton(
                  tooltip: 'View code',
                  onPressed: state._showCodeDialog,
                  icon: const Icon(Icons.code),
                ),
              ] else ...[
                ElevatedButton.icon(
                  onPressed: state._showCodeDialog,
                  icon: const Icon(Icons.code, size: 18),
                  label: const Text('Code'),
                ),
              ],
              IconButton(
                tooltip: 'GitHub',
                onPressed: state._openRepository,
                icon: const Icon(Icons.open_in_new),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE3E8EF)),
      ),
      child: child,
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    Key? key,
    required this.state,
    this.fillAvailableSpace = false,
  }) : super(key: key);

  final _WaveGeneratorHomeState state;
  final bool fillAvailableSpace;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final preview = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          WaveWidget(
            config: state._config(),
            backgroundColor: Color(state._palette.background),
            size: const Size(double.infinity, double.infinity),
            waveAmplitude: state._amplitude,
            isLoop: state._isLoop,
            duration: 8000,
          ),
          const _PreviewComposition(),
        ],
      ),
    );

    return _PanelCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live preview',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (fillAvailableSpace)
              Expanded(child: preview)
            else
              AspectRatio(
                aspectRatio: 16 / 10,
                child: preview,
              ),
          ],
        ),
      ),
    );
  }
}

class _PreviewComposition extends StatelessWidget {
  const _PreviewComposition({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final roomy =
              constraints.maxWidth >= 640 && constraints.maxHeight >= 420;
          return Padding(
            padding: EdgeInsets.all(roomy ? 28 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PreviewSkeletonBlock(
                  width: roomy ? constraints.maxWidth * 0.42 : 260,
                  height: roomy ? 92 : 72,
                  lines: roomy ? 3 : 2,
                ),
                if (roomy) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _PreviewSkeletonBlock(
                        width: constraints.maxWidth * 0.24,
                        height: 118,
                        lines: 3,
                      ),
                      const SizedBox(width: 16),
                      _PreviewSkeletonBlock(
                        width: constraints.maxWidth * 0.28,
                        height: 118,
                        lines: 4,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PreviewSkeletonBlock extends StatelessWidget {
  const _PreviewSkeletonBlock({
    Key? key,
    required this.width,
    required this.height,
    required this.lines,
  }) : super(key: key);

  final double width;
  final double height;
  final int lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xEFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xCCFFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x170F172A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List<Widget>.generate(lines, (index) {
          final factor = index == 0 ? 0.74 : (index.isEven ? 0.58 : 0.86);
          return Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 10),
            child: FractionallySizedBox(
              widthFactor: factor,
              alignment: Alignment.centerLeft,
              child: Container(
                height: index == 0 ? 12 : 8,
                decoration: BoxDecoration(
                  color: index == 0
                      ? const Color(0xFF0E7490)
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ControlsPanel extends StatelessWidget {
  const _ControlsPanel({
    Key? key,
    required this.state,
    this.fillAvailableSpace = false,
  }) : super(key: key);

  final _WaveGeneratorHomeState state;
  final bool fillAvailableSpace;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final header = Row(
      children: [
        Expanded(
          child: Text(
            'Controls',
            style: textTheme.titleLarge?.copyWith(
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _StatusDot(isActive: state._isLoop),
      ],
    );
    final controlBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModeSelector(state: state),
        const SizedBox(height: 18),
        _SectionLabel(
          label: state._mode == _ConfigMode.random ? 'Seed preset' : 'Palette',
        ),
        const SizedBox(height: 10),
        _PaletteSelector(state: state),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 8),
        _SliderControl(
          label: 'Layers',
          valueLabel: '${state._layers}',
          value: state._layers.toDouble(),
          min: _layersMin,
          max: _layersMax,
          divisions: 4,
          onChanged: state._setLayers,
        ),
        _SliderControl(
          label: 'Height',
          valueLabel: state._height.toStringAsFixed(2),
          value: state._height,
          min: _heightMin,
          max: _heightMax,
          divisions: 14,
          onChanged: state._setHeight,
        ),
        _SliderControl(
          label: 'Amplitude',
          valueLabel: state._amplitude.toStringAsFixed(1),
          value: state._amplitude,
          min: _amplitudeMin,
          max: _amplitudeMax,
          divisions: 14,
          onChanged: state._setAmplitude,
        ),
        _SliderControl(
          label: 'Speed',
          valueLabel: '${state._speed.toStringAsFixed(1)}x',
          value: state._speed,
          min: _speedMin,
          max: _speedMax,
          divisions: 12,
          onChanged: state._setSpeed,
        ),
        const SizedBox(height: 6),
        _LoopToggle(
          value: state._isLoop,
          onChanged: state._setLoop,
        ),
      ],
    );

    if (fillAvailableSpace) {
      return _PanelCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 14),
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: controlBody,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _PanelCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 14),
            controlBody,
          ],
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({Key? key, required this.state}) : super(key: key);

  final _WaveGeneratorHomeState state;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth / _ConfigMode.values.length)
            .clamp(84.0, 104.0)
            .toDouble();
        return ToggleButtons(
          constraints: BoxConstraints(
            minHeight: 38,
            minWidth: itemWidth,
          ),
          borderRadius: BorderRadius.circular(8),
          isSelected: _ConfigMode.values
              .map((mode) => mode == state._mode)
              .toList(growable: false),
          onPressed: (index) {
            state._setMode(_ConfigMode.values[index]);
          },
          children: _ConfigMode.values
              .map(
                (mode) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(_modeLabel(mode)),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({Key? key, required this.isActive}) : super(key: key);

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive ? const Color(0xFFBAE6FD) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color:
                  isActive ? const Color(0xFF0891B2) : const Color(0xFF94A3B8),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Loop' : 'Static',
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavbarPerformanceMonitor extends StatefulWidget {
  const _NavbarPerformanceMonitor({
    Key? key,
    required this.compact,
  }) : super(key: key);

  final bool compact;

  @override
  State<_NavbarPerformanceMonitor> createState() =>
      _NavbarPerformanceMonitorState();
}

class _NavbarPerformanceMonitorState extends State<_NavbarPerformanceMonitor> {
  Timer? _timer;
  int _sampleCount = 0;
  int _slowFrames = 0;
  double _totalFrameMs = 0;
  double _maxFrameMs = 0;
  _PerformanceStats _stats = const _PerformanceStats.empty();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_handleTimings);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _publishStats();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    SchedulerBinding.instance.removeTimingsCallback(_handleTimings);
    super.dispose();
  }

  void _handleTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final frameMs = timing.totalSpan.inMicroseconds / 1000;
      _sampleCount += 1;
      _totalFrameMs += frameMs;
      if (frameMs > _maxFrameMs) {
        _maxFrameMs = frameMs;
      }
      if (frameMs > 16.7) {
        _slowFrames += 1;
      }
    }
  }

  void _publishStats() {
    if (!mounted) return;
    if (_sampleCount == 0) {
      setState(() {
        _stats = const _PerformanceStats.empty();
      });
      return;
    }

    final averageFrameMs = _totalFrameMs / _sampleCount;
    final slowFramePercent = _slowFrames * 100 / _sampleCount;
    setState(() {
      _stats = _PerformanceStats(
        framesPerSecond: _sampleCount,
        averageFrameMs: averageFrameMs,
        maxFrameMs: _maxFrameMs,
        slowFramePercent: slowFramePercent,
      );
    });

    _sampleCount = 0;
    _slowFrames = 0;
    _totalFrameMs = 0;
    _maxFrameMs = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFDDE5EF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.speed, color: Color(0xFF0E7490), size: 18),
          const SizedBox(width: 8),
          _PerformanceMetric(
            label: 'FPS',
            value: _stats.hasData ? '${_stats.framesPerSecond}' : '--',
            valueWidth: 24,
          ),
          const SizedBox(width: 10),
          _PerformanceMetric(
            label: 'Frame',
            value: _stats.hasData
                ? '${_stats.averageFrameMs.toStringAsFixed(1)} ms'
                : '--',
            valueWidth: 52,
          ),
          if (!widget.compact) ...[
            const SizedBox(width: 10),
            _PerformanceMetric(
              label: 'Worst',
              value: _stats.hasData
                  ? '${_stats.maxFrameMs.toStringAsFixed(1)} ms'
                  : '--',
              valueWidth: 52,
            ),
            const SizedBox(width: 10),
            _PerformanceMetric(
              label: 'Slow',
              value: _stats.hasData
                  ? '${_stats.slowFramePercent.toStringAsFixed(0)}%'
                  : '--',
              valueWidth: 34,
            ),
          ],
        ],
      ),
    );
  }
}

class _PerformanceMetric extends StatelessWidget {
  const _PerformanceMetric({
    Key? key,
    required this.label,
    required this.value,
    required this.valueWidth,
  }) : super(key: key);

  final String label;
  final String value;
  final double valueWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: valueWidth,
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _PerformanceStats {
  const _PerformanceStats({
    required this.framesPerSecond,
    required this.averageFrameMs,
    required this.maxFrameMs,
    required this.slowFramePercent,
  });

  const _PerformanceStats.empty()
      : framesPerSecond = 0,
        averageFrameMs = 0,
        maxFrameMs = 0,
        slowFramePercent = 0;

  final int framesPerSecond;
  final double averageFrameMs;
  final double maxFrameMs;
  final double slowFramePercent;

  bool get hasData => framesPerSecond > 0;
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({Key? key, required this.label}) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF475569),
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _PaletteSelector extends StatelessWidget {
  const _PaletteSelector({Key? key, required this.state}) : super(key: key);

  final _WaveGeneratorHomeState state;

  @override
  Widget build(BuildContext context) {
    final usesSeedPresets = state._mode == _ConfigMode.random;
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth >= 300
            ? (constraints.maxWidth - 8) / 2
            : 156.0;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List<Widget>.generate(_palettes.length, (index) {
            final palette = _palettes[index];
            return SizedBox(
              width: itemWidth,
              child: _PaletteOption(
                palette: palette,
                usesSeedPreset: usesSeedPresets,
                selected: state._paletteIndex == index,
                onTap: () {
                  state._setPaletteIndex(index);
                },
              ),
            );
          }),
        );
      },
    );
  }
}

class _PaletteOption extends StatelessWidget {
  const _PaletteOption({
    Key? key,
    required this.palette,
    required this.usesSeedPreset,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  final _Palette palette;
  final bool usesSeedPreset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE0F2FE) : Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  selected ? const Color(0xFF0891B2) : const Color(0xFFDDE5EF),
            ),
          ),
          child: Row(
            children: [
              if (usesSeedPreset)
                const Icon(Icons.tag, color: Color(0xFF0E7490), size: 18)
              else
                _PaletteSwatches(colors: palette.colors),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  usesSeedPreset ? 'Seed ${palette.seed}' : palette.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check,
                  color: Color(0xFF0891B2),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaletteSwatches extends StatelessWidget {
  const _PaletteSwatches({Key? key, required this.colors}) : super(key: key);

  final List<int> colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 18,
      child: Stack(
        children: List<Widget>.generate(colors.length, (index) {
          return Positioned(
            left: index * 8.0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Color(colors[index]),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LoopToggle extends StatelessWidget {
  const _LoopToggle({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDDE5EF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.repeat, color: Color(0xFF475569), size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Loop animation',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SliderControl extends StatelessWidget {
  const _SliderControl({
    Key? key,
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  }) : super(key: key);

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final sliderValue = _clampSliderValue(value, min, max);

    return Padding(
      padding: const EdgeInsets.only(top: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  valueLabel,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: sliderValue,
              min: min,
              max: max,
              divisions: divisions,
              label: valueLabel,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

double _clampSliderValue(double value, double min, double max) {
  return value.clamp(min, max).toDouble();
}

class _CodeDialog extends StatelessWidget {
  const _CodeDialog({
    Key? key,
    required this.code,
    required this.onCopy,
  }) : super(key: key);

  final String code;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 900,
          maxHeight: size.height * 0.86,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: Row(
                children: [
                  const Icon(Icons.code, color: Color(0xFF0E7490)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Generated Flutter code',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFF0F172A),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SelectableText(
                        code,
                        style: const TextStyle(
                          color: Color(0xFFE5E7EB),
                          fontFamily: 'monospace',
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(
                  top: BorderSide(color: Color(0xFFDDE5EF)),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Copy this widget into any Flutter layout.',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    label: const Text('Copy code'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _modeLabel(_ConfigMode mode) {
  switch (mode) {
    case _ConfigMode.single:
      return 'Single';
    case _ConfigMode.random:
      return 'Seeded';
    case _ConfigMode.custom:
      return 'Custom';
  }
}

String _presetLabel(_WaveGeneratorHomeState state) {
  if (state._mode == _ConfigMode.random) {
    return 'seed ${state._palette.seed}';
  }
  return state._palette.name;
}

class _Palette {
  const _Palette({
    required this.name,
    required this.background,
    required this.seed,
    required this.colors,
  });

  final String name;
  final int background;
  final int seed;
  final List<int> colors;
}
