import 'package:flutter/widgets.dart';

class StrokeData {
  final Color color;
  final double width;

  const StrokeData({
    required this.color,
    required this.width,
  });

  StrokeData copyWith({
    Color? color,
    double? width,
  }) {
    return StrokeData(
      color: color ?? this.color,
      width: width ?? this.width,
    );
  }

  @override
  String toString() => 'StrokeData(color: $color, width: $width)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StrokeData && other.color == color && other.width == width;
  }

  @override
  int get hashCode => color.hashCode ^ width.hashCode;
}
