import 'package:flutter/material.dart';

typedef SideMenuAnimationBuilder = Widget Function(VoidCallback showMenu);
typedef SideMenuAnimationAppBarBuilder = AppBar Function(VoidCallback showMenu);

const _sideMenuWidth = 100.0;
const _sideMenuDuration = const Duration(milliseconds: 800);

class SideMenuAnimation extends StatefulWidget {
  const SideMenuAnimation.builder({
    Key key,
    this.builder,
    this.items,
    this.onItemSelected,
    this.selectedColor = Colors.black,
    this.unselectedColor = Colors.green,
    this.menuWidth = _sideMenuWidth,
    this.duration = _sideMenuDuration,
  })  : this.views = null,
        this.appBarBuilder = null,
        super(key: key);

  const SideMenuAnimation({
    Key key,
    this.views,
    this.items,
    this.onItemSelected,
    this.selectedColor = Colors.black,
    this.unselectedColor = Colors.green,
    this.menuWidth = _sideMenuWidth,
    this.duration = _sideMenuDuration,
    this.appBarBuilder,
  })  : this.builder = null,
        super(key: key);

  final SideMenuAnimationBuilder builder;
  final SideMenuAnimationAppBarBuilder appBarBuilder;
  final List<Widget> items;
  final ValueChanged<int> onItemSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final double menuWidth;
  final Duration duration;
  final List<Widget> views;

  @override
  _SideMenuAnimationState createState() => _SideMenuAnimationState();
}

class _SideMenuAnimationState extends State<SideMenuAnimation> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  List<Animation<double>> _animations;

  int _selectedIndex = 1;
  int _oldSelectedIndex = 1;
  bool wasZeroIndexPressed = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    final _intervalGap = 1 / widget.items.length;
    _animations = List.generate(
        widget.items.length,
        (index) => Tween(begin: 0.0, end: 1.6).animate(
              CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    index * _intervalGap,
                    index * _intervalGap + _intervalGap,
                  )),
            )).toList();
    _animationController.forward(from: 1.0);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: LayoutBuilder(builder: (context, constraints) {
        final itemSize = constraints.maxHeight / widget.items.length;
        return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                children: [
                  if (widget.builder != null)
                    widget.builder(
                      () {
                        _animationController.reverse();
                      },
                    ),
                  if (widget.appBarBuilder != null)
                    Scaffold(
                      appBar: widget.appBarBuilder(
                        () {
                          _animationController.reverse();
                        },
                      ),
                      body: Stack(
                        children: [
                          widget.views[_oldSelectedIndex],
                          ClipPath(
                            clipper: _MainSideMenuClipper(
                              _animationController.status == AnimationStatus.forward &&
                                      _selectedIndex != _oldSelectedIndex &&
                                      !wasZeroIndexPressed
                                  ? Tween(begin: 0.0, end: 3.0).animate(_animationController).value
                                  : 3.0,
                            ),
                            child: widget.views[_selectedIndex],
                          ),
                        ],
                      ),
                    ),
                  for (int i = 0; i < widget.items.length; i++)
                    Positioned(
                      left: 0,
                      top: itemSize * i,
                      width: widget.menuWidth,
                      height: itemSize,
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(_animationController.status == AnimationStatus.reverse
                              ? -_animations[widget.items.length - 1 - i].value
                              : -_animations[i].value),
                        alignment: Alignment.topLeft,
                        child: Material(
                          color: i == _selectedIndex ? widget.selectedColor : widget.unselectedColor,
                          child: InkWell(
                            onTap: () {
                              _animationController.forward(from: 0.0);
                              if (i != 0) {
                                setState(() {
                                  _oldSelectedIndex = _selectedIndex;
                                  _selectedIndex = i;
                                });
                                wasZeroIndexPressed = false;
                              } else {
                                wasZeroIndexPressed = true;
                              }
                              widget.onItemSelected(i);
                            },
                            child: widget.items[i],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            });
      }),
    );
  }
}

class _MainSideMenuClipper extends CustomClipper<Path> {
  final double percent;

  _MainSideMenuClipper(this.percent);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width * percent,
        height: size.height * percent,
      ),
    );
    return path;
  }

  @override
  bool shouldReclip(covariant _MainSideMenuClipper oldClipper) => oldClipper.percent != percent;
}
