import 'package:flutter/material.dart';

/// Signature for creating a widget with a `showMenu` callback
/// for opening the Side Menu.
///
/// See also:
/// * [SideMenuAnimation.builder]
/// * [SideMenuAnimationAppBarBuilder]
typedef SideMenuAnimationBuilder = Widget Function(VoidCallback showMenu);

/// Signature for creating an [AppBar] widget with a
/// `showMenu` callback for opening the Side Menu.
///
/// See also:
/// * [SideMenuAnimation].
typedef SideMenuAnimationAppBarBuilder = AppBar Function(VoidCallback showMenu);

const _sideMenuWidth = 100.0;
const _sideMenuDuration = Duration(milliseconds: 800);
const _kEdgeDragWidth = 20.0;

/// # SideMenuPosition
/// This enum is the position selector of the menu.
///
/// {@template SideMenuPosition.right}
/// ## right
/// Set the position of the menu in the right side on the screen
/// {@endtemplate}
///
/// {@template SideMenuPosition.left}
/// ## left
/// Set the position of the menu in the left side on the screen
/// {@endtemplate}
enum SideMenuPosition {
  /// {@macro SideMenuPosition.right}
  right,

  /// {@macro SideMenuPosition.left}
  left,
}

extension _SideMenuPositionX on SideMenuPosition {
  bool get isLeft => this == SideMenuPosition.left;
  bool get isRight => this == SideMenuPosition.right;
}

/// The [SideMenuAnimation] controls the items from the lateral menu
/// and also can control the circular reveal transition.
class SideMenuAnimation extends StatefulWidget {
  /// Creates a [SideMenuAnimation] without Circular Reveal animation.
  /// Also it is responsible for updating/changing the [AppBar]
  /// based on the index we receive.
  const SideMenuAnimation.builder({
    Key? key,
    required this.builder,
    required this.items,
    required this.onItemSelected,
    this.position = SideMenuPosition.left,
    this.selectedColor = Colors.black,
    this.unselectedColor = Colors.green,
    double? menuWidth,
    Duration? duration,
    this.tapOutsideToDismiss = false,
    this.scrimColor = Colors.transparent,
    double? edgeDragWidth,
    this.enableEdgeDragGesture = false,
    this.curveAnimation = Curves.linear,
  })  : views = null,
        appBarBuilder = null,
        indexSelected = null,
        menuWidth = menuWidth ?? _sideMenuWidth,
        duration = duration ?? _sideMenuDuration,
        edgeDragWidth = edgeDragWidth ?? _kEdgeDragWidth,
        super(key: key);

  /// Creates a [SideMenuAnimation] with Circular Reveal animation.
  /// Also it is responsible for updating/changing the [AppBar]
  /// based on the index we receive.
  const SideMenuAnimation({
    Key? key,
    required this.views,
    required this.items,
    required this.onItemSelected,
    this.position = SideMenuPosition.left,
    this.selectedColor = Colors.black,
    this.unselectedColor = Colors.green,
    double? menuWidth,
    Duration? duration,
    this.appBarBuilder,
    this.indexSelected = 0,
    this.tapOutsideToDismiss = false,
    this.scrimColor = Colors.transparent,
    double? edgeDragWidth,
    this.enableEdgeDragGesture = false,
    this.curveAnimation = Curves.linear,
  })  : builder = null,
        menuWidth = menuWidth ?? _sideMenuWidth,
        duration = duration ?? _sideMenuDuration,
        edgeDragWidth = edgeDragWidth ?? _kEdgeDragWidth,
        super(key: key);

  /// `builder` builds a view/page based on the `selectedIndex.
  /// It also comes with a `showMenu` callback for opening the Side Menu.
  final SideMenuAnimationBuilder? builder;

  /// `appBarBuilder` returns an [AppBar] based on the `selectedIndex`
  /// It also comes with the `showMenu` callback
  /// where we can use to open the Side Menu.
  final SideMenuAnimationAppBarBuilder? appBarBuilder;

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

  /// Duration for the animation when the menu appears, this is
  /// the total duration, each item has total_duration/items.lenght
  final Duration duration;

  /// Pages/Views we pass to the widge to display with a circular
  /// reveal animation
  final List<Widget>? views;

  /// Initial index selected
  final int? indexSelected;

  /// Enables to dismiss the [SideMenuAnimation] when user taps outside
  /// the widget.
  /// It's `false` by default.
  final bool tapOutsideToDismiss;

  /// Defines the `position` of the sider menu: `left` of `right`.
  /// By default it is [SideMenuPosition.left].
  final SideMenuPosition position;

  /// If `tapOutsideToDismiss` is true, then the `scrimColor` is enabled
  /// to change, this is the panel where we tap to dismiss the Side Menu.
  final Color scrimColor;

  /// Enables swipe from left to right to display the menu,
  /// it's `false` by default.
  final bool enableEdgeDragGesture;

  /// If `enableEdgeDragGesture` is true, then we can change
  /// the `edgeDragWidth`, this is the width of the area where we do swipe.
  final double edgeDragWidth;

  /// [Curve] used for the animation
  final Curve curveAnimation;

  @override
  _SideMenuAnimationState createState() => _SideMenuAnimationState();
}

class _SideMenuAnimationState extends State<SideMenuAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  late int _selectedIndex;
  late int _oldSelectedIndex;
  int _selectedColor = 1;

  late ColorTween _scrimColorTween;

  @override
  void initState() {
    _selectedIndex = widget.indexSelected ?? 0;
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
            _intervalGap * index,
            _intervalGap * (index + 1),
            curve: widget.curveAnimation,
          ),
        ),
      ),
    );
  }

  void _createColorTween() {
    _scrimColorTween = ColorTween(
      end: Colors.transparent,
      begin: widget.scrimColor,
    );
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
    _animationController.dispose();
    super.dispose();
  }

  void _displayMenuDragGesture(DragEndDetails endDetails) {
    final velocity = endDetails.primaryVelocity!;
    if (widget.position.isLeft) {
      if (velocity > 0) _animationReverse();
    } else {
      if (velocity < 0) _animationReverse();
    }
  }

  void _animationReverse() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemSize = constraints.maxHeight / widget.items.length;
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => Stack(
              children: [
                if (widget.builder != null) widget.builder!(_animationReverse),
                if (widget.appBarBuilder != null)
                  Scaffold(
                    appBar: widget.appBarBuilder!(_animationReverse),
                    body: CircularApearing(
                      child: widget.views![_oldSelectedIndex],
                      enteringChild: widget.views![_selectedIndex],
                      animationController: _animationController,
                      dx: widget.position.isLeft ? 0.0 : constraints.maxWidth,
                      dy: (itemSize * _selectedIndex) + (itemSize / 2),
                    ),
                  ),
                if (widget.tapOutsideToDismiss &&
                    _animationController.value < 1)
                  Align(
                    child: GestureDetector(
                      onTap: () => _animationController.forward(from: 0.0),
                      child: AnimatedContainer(
                        duration: widget.duration,
                        color: _scrimColorTween.evaluate(
                          Tween(begin: 0.0, end: 1.0)
                              .animate(_animationController),
                        ),
                      ),
                    ),
                  ),
                if (widget.enableEdgeDragGesture &&
                    _animationController.isCompleted)
                  Align(
                    alignment: widget.position.isLeft
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: GestureDetector(
                      onHorizontalDragEnd: _displayMenuDragGesture,
                      behavior: HitTestBehavior.translucent,
                      excludeFromSemantics: true,
                      child: Container(width: widget.edgeDragWidth),
                    ),
                  ),
                for (int i = 0; i < widget.items.length; i++)
                  Positioned(
                    left: widget.position.isLeft ? 0 : null,
                    right: widget.position.isRight ? 0 : null,
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
                      alignment: widget.position.isRight
                          ? Alignment.topRight
                          : Alignment.topLeft,
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
                            }
                            widget.onItemSelected(i);
                          },
                          child: widget.items[i],
                        ),
                      ),
                    ),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}

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
        oldWidget.enteringChild != oldWidget.enteringChild) {
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
