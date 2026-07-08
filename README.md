# WAVE

<img src='https://github.com/glorylab/wave/blob/master/assets/wave_banner.png?raw=true' width="1000" height="auto" alt="Flutter package: tm - WAVE" />

---

[![Awesome: Flutter](https://img.shields.io/badge/⌐◨─◨-AwesomeFlutter-blue.svg?logo=flutter&longCache=true&style=flat-square)](https://github.com/Solido/awesome-flutter#effect) 
[![Pub](https://img.shields.io/pub/v/wave.svg?logo=flutter&style=flat-square)](https://pub.dev/packages/wave)
![GitHub](https://img.shields.io/github/license/mashape/apistatus.svg?longCache=true&style=flat-square)

A Flutter package for displaying waves.

## Demo

| Platform  | Branch    | URL   | 
| -:        | -:        | -:    |
| Web       | `master`  | [wave.glorylab.xyz](https://wave.glorylab.xyz "The demo page of the wave package.") |
| Web       | `develop` | [dev.wave.glorylab.xyz](https://dev.wave.glorylab.xyz "The demo page of the wave package's develop branch.") |



## Getting Started

``` Dart

static const _backgroundColor = Color(0xFFF15BB5);

static const _colors = [
    Color(0xFFFEE440),
    Color(0xFF00BBF9),
];

static const _durations = [
    5000,
    4000,
];

static const _heightPercentages = [
    0.65,
    0.66,
];

WaveWidget(
    config: CustomConfig(
        colors: _colors,
        durations: _durations,
        heightPercentages: _heightPercentages,
    ),
    backgroundColor: _backgroundColor,
    size: Size(double.infinity, double.infinity),
    waveAmplitude: 0,
),
```

## Config modes

`CustomConfig` is the most explicit mode. Use it when you want full control over
each wave layer's colors or gradients, duration, and height.

``` Dart
WaveWidget(
    config: CustomConfig(
        gradients: [
            [Color(0xFF00BBF9), Color(0xFF9B5DE5)],
            [Color(0xFFFEE440), Color(0xFFF15BB5)],
        ],
        durations: [5000, 4000],
        heightPercentages: [0.65, 0.66],
    ),
    size: Size(double.infinity, double.infinity),
)
```

`SingleConfig` creates layered waves from one color. `RandomConfig` creates
layer colors for you, with an optional `seed` when deterministic output is
useful for tests or demos.

``` Dart
WaveWidget(
    config: SingleConfig(
        color: Color(0xFF00BBF9),
        layers: 3,
    ),
    size: Size(double.infinity, double.infinity),
)

WaveWidget(
    config: RandomConfig(
        seed: 7,
        layers: 4,
    ),
    size: Size(double.infinity, double.infinity),
)
```
