library wave;

import 'package:flutter/widgets.dart';

class DefaultConfig {
  static const int duration = 1000;
  static const double height = 128.0;
  static const double topAlpha = 0.6;
  static const double bottomAlpha = 1.0;
  static const Color color = /* blue */ Color(0xFF2196F3);
  static const Color backgroundColor = /* white */ Color(0xFFFFFF);
  static const Curve curve = Curves.fastOutSlowIn;
}

class Wave extends StatefulWidget {
  /// Duration(milliseconds) of wave's animation.
  final int duration;

  /// Height of Wave Widget.
  final double height;

  /// Wave's alpha of top
  final double topAlpha;

  /// Wave's alpha of bottom
  final double bottomAlpha;

  /// Primary color.
  final Color color;

  /// Color of background.
  final Color backgroundColor;

  /// Curve of wave's animation.
  final Curve curve;

  const Wave({
    Key key,
    this.duration: DefaultConfig.duration,
    this.height: DefaultConfig.height,
    this.topAlpha: DefaultConfig.topAlpha,
    this.bottomAlpha: DefaultConfig.bottomAlpha,
    this.color: DefaultConfig.color,
    this.backgroundColor: DefaultConfig.backgroundColor,
    this.curve: DefaultConfig.curve,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => WaveState();
}

class WaveState extends State<Wave> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;
  CurvedAnimation _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: Duration(milliseconds: widget.duration),
        vsync: this,
        animationBehavior: AnimationBehavior.preserve);
    _curve = CurvedAnimation(parent: _controller, curve: widget.curve);
    _animation = Tween(begin: 0.00001, end: 0.99999).animate(_curve);
    _animation.addListener(() {
      switch (_controller.status) {
        case AnimationStatus.completed:
          _controller.reverse();
          break;
        case AnimationStatus.dismissed:
          _controller.forward();
          break;
        default:
          break;
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: AnimatedBuilder(
        animation: _animation,
        child: Container(color: Color(0xFFFFFFFF)),
        builder: (BuildContext context, Widget child) {
          return ClipPath(
            clipper: WaveClipper(
              cp1xp: _controller.value,
              cp1yp: _controller.value,
              ep1p: Offset(0.6 - 0.2 * _controller.value, _controller.value),
              leftHeightP: _controller.value,
            ),
            child: Container(
              height: widget.height,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(
                          widget.color.red,
                          widget.color.green,
                          widget.color.blue,
                          widget.topAlpha * _controller.value),
                      Color.fromRGBO(
                          widget.color.red,
                          widget.color.green,
                          widget.color.blue,
                          0.6 + 0.4 * (widget.bottomAlpha * _controller.value)),
                    ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  /// `control point 1`'s percentage of half the width
  final double cp1xp;

  /// `control point 1`'s percentage of half the height
  final double cp1yp;

  final Offset ep1p;
  final double leftHeightP;

  WaveClipper({
    @required this.cp1xp,
    this.cp1yp,
    this.ep1p,
    this.leftHeightP,
  });

  @override
  Path getClip(Size size) {
    var path = new Path();

    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);

    double rightPoint =
        size.height - size.height / 3 - size.height * leftHeightP / 3;
    path.lineTo(size.width, rightPoint);

    double endPointX = size.width * ep1p.dx;
    double endPointY = size.height / 2 + size.height * (0.5 - ep1p.dy) / 2;

    double cp1x = endPointX + (size.width / 6) + (cp1xp * size.width * 1 / 6);
    double cp1y = endPointY - cp1yp * endPointY;

    var cp1 = Offset(cp1x, cp1y);

    path.quadraticBezierTo(cp1.dx, cp1.dy, endPointX, endPointY);

    double cp3x = (endPointX - cp1x) + endPointX;
    double cp3y = (endPointY - cp1y) + endPointY;

    var cp3 = Offset(cp3x, cp3y);
    var ep3 = Offset(0, size.height - rightPoint);
    path.quadraticBezierTo(cp3.dx, cp3.dy, ep3.dx, ep3.dy);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
