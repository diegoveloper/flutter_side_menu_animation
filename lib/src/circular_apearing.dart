import 'package:flutter/widgets.dart';

/// {@template CircularApearing}
/// Creates an animation where a new widget apears in from of another one
/// as circle with increasing radius with a center positioned in (`dx`, `dy`).
/// {@endtemplate}
class CircularApearing extends StatefulWidget {
  /// {@macro CircularApearing}
  const CircularApearing({
    Key? key,
    required this.child,
    this.enteringChild,
    required this.dx,
    required this.dy,
    required this.animationController,
  }) : super(key: key);

  /// [Widget] `child` that is currently shown
  final Widget child;

  /// `enteringChild` with the [CircularApearing] animation
  final Widget? enteringChild;

  /// Initial position in the X-axis for the [CircularApearing] animation
  final double dx;

  /// Initial position in the Y-axis for the [CircularApearing] animation
  final double dy;

  /// `animationcontroller` for [CircularApearing] animation
  final AnimationController animationController;

  @override
  _CircularApearingState createState() => _CircularApearingState();
}

class _CircularApearingState extends State<CircularApearing> {
  late Widget child;
  Widget? enteringChild;

  @override
  void initState() {
    super.initState();
    child = widget.child;
    enteringChild = widget.enteringChild;
    widget.animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && enteringChild != null) {
        setState(() {
          child = enteringChild!;
          enteringChild = null;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant CircularApearing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child ||
        oldWidget.enteringChild != widget.enteringChild) {
      child = widget.child;
      enteringChild = widget.enteringChild;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (enteringChild != null)
          ClipPath(
            clipper: _CircularApearingClipper(
              end: 3.0,
              dx: widget.dx,
              dy: widget.dy,
              controller: widget.animationController,
            ),
            child: enteringChild,
          ),
      ],
    );
  }
}

class _CircularApearingClipper extends CustomClipper<Path> {
  _CircularApearingClipper({
    required this.end,
    required this.dx,
    required this.dy,
    required this.controller,
  })   : assert(end > 0.0),
        super(reclip: controller);

  final double end;
  final double dx, dy;
  final AnimationController controller;

  @override
  Path getClip(Size size) {
    final percent = controller.status == AnimationStatus.forward
        ? Tween(begin: 0.0, end: 3.0).animate(controller).value
        : 3.0;
    return Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(dx, dy),
          width: size.width * percent,
          height: size.height * percent,
        ),
      );
  }

  @override
  bool shouldReclip(covariant _CircularApearingClipper oldClipper) =>
      oldClipper.end != end;
}
