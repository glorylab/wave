# Wave

[![pub package](https://img.shields.io/pub/v/wave.svg)](https://pub.dartlang.org/packages/wave)

Widget for displaying a wave, with custom duration, size, color, alpha and so on.

## Getting Started

``` dart
    WaveWidget(
        colorMode: ColorMode.custom,
        colors: [
            Colors.white70,
            Colors.white54,
            Colors.white30,
            Colors.white24,
        ],
        durations: [
            32000,
            21000,
            18000,
            5000,
        ],
        waveAmplitude: 0,
        heightPercentages: [0.25, 0.26, 0.28, 0.31],
        backgroundColor: Colors.blue,
        size: Size(double.infinity, double.infinity),
    ),
```

![demo](example/assets/demo.PNG)

![demo](example/assets/demo.gif)

