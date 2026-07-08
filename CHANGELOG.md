# CHANGELOG

## Unreleased

* Preserve source compatibility while documenting legacy APIs.
* Make `CustomConfig` snapshot mutable input lists like the other config modes.
* Add regression tests for config validation, runtime config updates, and
  deterministic seeded random colors.
* Clarify Cloudflare deployment docs and package license attribution.

## 0.2.5

* Improve `WaveWidget` paint performance for long-duration, high-amplitude
  wave configurations like GitHub issue #53.
* Add a manual benchmark for the issue #53 scenario and regression coverage for
  runtime amplitude updates.

## 0.2.4

* Expand Dart SDK compatibility to allow Dart 3.
* Add CI coverage for both Flutter 3.7.12 and the latest stable Flutter.
* Avoid deprecated color opacity APIs on current Flutter.
* Add dartdoc coverage for the main public API.
* Replace the reusable publish workflow with Node 24 compatible publish steps.
* Expand README usage guidance with minimal examples, parameter tables, and common errors.
* Refresh the example app with a Material 3 generator, live performance metrics, and copyable code output.

## 0.2.3

* Add runtime validation for custom gradient and layer configuration.
* Add default rendering support for `SingleConfig` and `RandomConfig`.
* Improve animation lifecycle handling in `WaveWidget`.
* Add CI coverage for analyze and tests on Flutter 3.7.

## 0.2.2

Update banner.

## 0.2.1

Modify README and web version example, etc.

## 0.2.0

Migrate to null safety.

## 0.1.0

Add backgroundImage param.

## 0.0.7

Add options of setting blur and gradient.

## 0.0.6

* Widget for displaying a wave. Added options for custom waves and remove the image from [WaveView](https://github.com/While1true/WaveView_flutter).
