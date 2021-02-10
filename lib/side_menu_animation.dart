import 'package:flutter/material.dart';

/// Signature for a function that creates a widget with a `showMenu` callback which allow us to invoke and open the Side Menu.
/// Used by [SideMenuAnimation.builder].
typedef SideMenuAnimationBuilder = Widget Function(VoidCallback showMenu);

/// Signature for a function that creates an [AppBar] widget with a `showMenu` callback which allow us to invoke and open the Side Menu.
/// Used by [SideMenuAnimation].
typedef SideMenuAnimationAppBarBuilder = AppBar Function(VoidCallback showMenu);

const _sideMenuWidth = 100.0;
const _sideMenuDuration = const Duration(milliseconds: 800);
const _kEdgeDragWidth = 20.0;

/// This is the main widget which controls the items from the lateral menu and also can control the pages with a circular reveal animation.
class SideMenuAnimation extends StatefulWidget {
  /// Constructor to allow us to create a [SideMenuAnimation] without Circular Reveal animation.
  /// We are responsible for updating/changing the page based on the index we receive.
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
    this.edgeDragWidth = _kEdgeDragWidth,
    this.enableEdgeDragGesture = false,
  })  : this.views = null,
        this.appBarBuilder = null,
        this.indexSelected = null,
        assert(items != null, "items can't be null"),
        super(key: key);

  /// Constructor to allow us to create a [SideMenuAnimation] with Circular Reveal animation.
  /// We are responsible for updating/changing the [AppBar] based on the index we receive.
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
    this.edgeDragWidth = _kEdgeDragWidth,
    this.enableEdgeDragGesture = false,
  })  : this.builder = null,
        assert(items != null, "Items can't be null"),
        assert(views != null, "Views can't be null"),
        super(key: key);

  /// Builder where we have to return our view/page based on the index we have, it also comes with the `showMenu` callback where we can use to open the Side Menu.
  final SideMenuAnimationBuilder builder;

  /// Builder where we have to return our [AppBar] based on the index we have, it also comes with the `showMenu` callback where we can use to open the Side Menu.
  final SideMenuAnimationAppBarBuilder appBarBuilder;

  /// List of items that we want to display on the Side Menu.
  final List<Widget> items;

  /// Function where we receive the current index selected.
  final ValueChanged<int> onItemSelected;

  /// [Color] used for the background of the selected item.
  final Color selectedColor;

  /// [Color] used for the background of the unselected item.
  final Color unselectedColor;

  /// Menu width for the Side Menu.
  final double menuWidth;

  /// Duration for the animation when the menu appears, this is the total duration, each item has total_duration/items.lenght
  final Duration duration;

  /// Pages/Views we pass to the widge to display with a circular reveal animation
  final List<Widget> views;

  /// Initial index selected
  final int indexSelected;

  /// If we want to tap outside the menu to dismiss the Side Menu, set this to `true`. It's `false` by default.
  final bool tapOutsideToDismiss;

  /// If `tapOutsideToDismiss` is true, then we can change the `scrimColor`, this is the panel where we tap to dismiss the Side Menu.
  final Color scrimColor;

  /// Enable swipe from left to right to display the menu, it's `false` by default. `enableEdgeDragGesture`
  final bool enableEdgeDragGesture;

  /// If `enableEdgeDragGesture` is true, then we can change the `edgeDragWidth`, this is the width of the area where we do swipe.
  final double edgeDragWidth;

  @override
  _SideMenuAnimationState createState() => _SideMenuAnimationState();
}

class _SideMenuAnimationState extends State<SideMenuAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  List<Animation<double>> _animations;

  int _selectedIndex;
  int _selectedColor = 1;
  int _oldSelectedIndex;
  bool _dontAnimate = false;
  ColorTween _scrimColorTween;

  @override
  void initState() {
    _selectedIndex = widget.indexSelected;
    _oldSelectedIndex = _selectedIndex;
    _animationController =
        AnimationController(vsync: this, duration: widget.duration);
    _createAnimations();
    _animationController.forward(from: 1.0);
    _createColorTween();
    super.initState();
  }

  void _createAnimations() {
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
  }

  void _createColorTween() {
    _scrimColorTween =
        ColorTween(end: Colors.transparent, begin: widget.scrimColor);
  }

  @override
  void didUpdateWidget(SideMenuAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrimColor != widget.scrimColor) _createColorTween();
    if (oldWidget.items.length != widget.items.length) _createAnimations();
    if (oldWidget.duration != widget.duration) {
      _animationController.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _displayMenuLeftToRight(DragEndDetails endDetails) {
    double velocity = endDetails.primaryVelocity;
    if (velocity > 0) _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemSize = constraints.maxHeight / widget.items.length;
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                children: [
                  if (widget.builder != null)
                    widget.builder(() => _animationController.reverse()),
                  if (widget.appBarBuilder != null)
                    Scaffold(
                      appBar: widget
                          .appBarBuilder(() => _animationController.reverse()),
                      body: Stack(
                        children: [
                          if (widget.views.length > 0) ...[
                            widget.views[_oldSelectedIndex],
                            ClipPath(
                              clipper: _MainSideMenuClipper(
                                percent: _animationController.status ==
                                            AnimationStatus.forward &&
                                        _selectedIndex != _oldSelectedIndex &&
                                        !_dontAnimate
                                    ? Tween(begin: 0.0, end: 3.0)
                                        .animate(_animationController)
                                        .value
                                    : 3.0,
                                dy: (itemSize * _selectedIndex) +
                                    (itemSize / 2),
                              ),
                              child: widget.views[_selectedIndex],
                            )
                          ],
                        ],
                      ),
                    ),
                  if (widget.tapOutsideToDismiss &&
                      _animationController.value < 1)
                    Align(
                      child: GestureDetector(
                        onTap: () {
                          _dontAnimate = true;
                          _animationController.forward(from: 0.0);
                        },
                        child: AnimatedContainer(
                          duration: widget.duration,
                          color: _scrimColorTween.evaluate(
                              Tween(begin: 0.0, end: 1.0)
                                  .animate(_animationController)),
                        ),
                      ),
                    ),
                  if (widget.enableEdgeDragGesture &&
                      _animationController.isCompleted)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onHorizontalDragEnd: _displayMenuLeftToRight,
                        behavior: HitTestBehavior.translucent,
                        excludeFromSemantics: true,
                        child: Container(width: widget.edgeDragWidth),
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
                          ..rotateY(_animationController.status ==
                                  AnimationStatus.reverse
                              ? -_animations[widget.items.length - 1 - i].value
                              : -_animations[i].value),
                        alignment: Alignment.topLeft,
                        child: Material(
                          color: (i == _selectedColor)
                              ? widget.selectedColor
                              : widget.unselectedColor,
                          child: InkWell(
                            onTap: () {
                              _animationController.forward(from: 0.0);
                              if (i != 0) {
                                setState(() {
                                  _oldSelectedIndex = _selectedIndex;
                                  _selectedIndex = i - 1;
                                  _selectedColor = i;
                                });
                                _dontAnimate = false;
                              } else {
                                _dontAnimate = true;
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
            },
          );
        },
      ),
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
  bool shouldReclip(covariant _MainSideMenuClipper oldClipper) =>
      oldClipper.percent != percent;
}
