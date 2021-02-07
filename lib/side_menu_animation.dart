import 'package:flutter/material.dart';

typedef SideMenuAnimationBuilder = Widget Function(VoidCallback showMenu);
typedef SideMenuAnimationAppBarBuilder = AppBar Function(VoidCallback showMenu);

const _sideMenuWidth = 100.0;
const _sideMenuDuration = const Duration(milliseconds: 800);

class SideMenuAnimation extends StatefulWidget {
  const SideMenuAnimation.builder({
    Key key,
    @required this.builder,
    @required this.items,
    @required this.onItemSelected,
    this.selectedColor = Colors.black,
    this.unselectedColor = Colors.green,
    this.menuWidth = _sideMenuWidth,
    this.duration = _sideMenuDuration,
    this.tapOutsideToDismiss = false,
    this.scrimColor = Colors.transparent,
  })  : this.views = null,
        this.appBarBuilder = null,
        this.indexSelected = null,
        assert(items != null, "items can't be null"),
        super(key: key);

  const SideMenuAnimation({
    Key key,
    @required this.views,
    @required this.items,
    @required this.onItemSelected,
    this.selectedColor = Colors.black,
    this.unselectedColor = Colors.green,
    this.menuWidth = _sideMenuWidth,
    this.duration = _sideMenuDuration,
    this.appBarBuilder,
    this.indexSelected = 0,
    this.tapOutsideToDismiss = false,
    this.scrimColor = Colors.transparent,
  })  : this.builder = null,
        assert(items != null, "items can't be null"),
        assert(views != null, "views can't be null"),
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
  final int indexSelected;
  final bool tapOutsideToDismiss;
  final Color scrimColor;

  @override
  _SideMenuAnimationState createState() => _SideMenuAnimationState();
}

class _SideMenuAnimationState extends State<SideMenuAnimation> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  List<Animation<double>> _animations;

  int _selectedIndex;
  int _selectedColor = 1;
  int _oldSelectedIndex;
  bool wasZeroIndexPressed = false;
  ColorTween _scrimColorTween;

  @override
  void initState() {
    _selectedIndex = widget.indexSelected;
    _oldSelectedIndex = _selectedIndex;
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
    _scrimColorTween = ColorTween(end: Colors.transparent, begin: widget.scrimColor);
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
                          if (widget.views.length > 0) ...[
                            widget.views[_oldSelectedIndex],
                            ClipPath(
                              clipper: _MainSideMenuClipper(
                                percent: _animationController.status == AnimationStatus.forward &&
                                        _selectedIndex != _oldSelectedIndex &&
                                        !wasZeroIndexPressed
                                    ? Tween(begin: 0.0, end: 3.0).animate(_animationController).value
                                    : 3.0,
                                dy: itemSize * _selectedIndex,
                              ),
                              child: widget.views[_selectedIndex],
                            )
                          ],
                        ],
                      ),
                    ),
                  if (widget.tapOutsideToDismiss && _animationController.value < 1)
                    Align(
                      child: GestureDetector(
                        onTap: () => _animationController.forward(from: 0.0),
                        child: AnimatedContainer(
                          duration: widget.duration,
                          color: _scrimColorTween.evaluate(Tween(begin: 0.0, end: 1.0).animate(_animationController)),
                        ),
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
                          color: (i == _selectedColor) ? widget.selectedColor : widget.unselectedColor,
                          child: InkWell(
                            onTap: () {
                              _animationController.forward(from: 0.0);
                              if (i != 0) {
                                setState(() {
                                  _oldSelectedIndex = _selectedIndex;
                                  _selectedIndex = i - 1;
                                  _selectedColor = i;
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
  final double dy;
  _MainSideMenuClipper({this.percent, this.dy});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addOval(
      Rect.fromCenter(
        center: Offset(0.0, dy),
        width: size.width * percent,
        height: size.height * percent,
      ),
    );
    return path;
  }

  @override
  bool shouldReclip(covariant _MainSideMenuClipper oldClipper) => oldClipper.percent != percent;
}
