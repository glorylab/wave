# Wave

<img src='../assets/wave-128.png' width="128" height="128" alt="Flutter package: WAVE" />

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
        colors: colors,
        durations: _durations,
        heightPercentages: _heightPercentages,
    ),
    backgroundColor: _backgroundColor,
    size: Size(double.infinity, double.infinity),
    waveAmplitude: 0,
),
```