import 'package:flutter/material.dart';

import 'src/circular_apearing.dart';

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
    _animationController.forward(from: 1.0);
    _createColorTween();
    super.initState();
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
          return Stack(
            children: [
              if (widget.builder != null) widget.builder!(_animationReverse),
              if (widget.appBarBuilder != null)
                Scaffold(
                  appBar: widget.appBarBuilder!(_animationReverse),
                  body: CircularApearing(
                    animationController: _animationController,
                    dx: widget.position.isLeft ? 0.0 : constraints.maxWidth,
                    dy: (itemSize * _selectedIndex) + (itemSize / 2),
                    child: widget.views![_oldSelectedIndex],
                    enteringChild: widget.views![_selectedIndex],
                  ),
                ),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) => Stack(
                  children: [
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
                      MenuItem(
                        position: widget.position,
                        index: i,
                        length: widget.items.length,
                        width: widget.menuWidth,
                        height: itemSize,
                        controller: _animationController,
                        curve: widget.curveAnimation,
                        color: (i == _selectedColor)
                            ? widget.selectedColor
                            : widget.unselectedColor,
                        onTap: () {
                          if (i != _selectedColor) {
                            if (i != 0) {
                              setState(() {
                                _oldSelectedIndex = _selectedIndex;
                                _selectedIndex = i - 1;
                                _selectedColor = i;
                              });
                            }
                            widget.onItemSelected(i);
                          }
                        },
                        child: widget.items[i],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// {@template MenuItem}
/// A [MenuItem] for the [SideMenuAnimation]
/// {@endtemplate}
class MenuItem extends StatelessWidget {
  /// {@macro MenuItem}
  const MenuItem({
    Key? key,
    required this.position,
    required this.index,
    required this.length,
    required this.width,
    required this.height,
    required this.child,
    required this.curve,
    required this.controller,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  /// `position` for the menu
  final SideMenuPosition position;

  /// `index` for the [MenuItem]
  final int index;

  /// Number of items
  final int length;

  /// `width` for the [MenuItem]
  final double width;

  /// `height` for the [MenuItem]
  final double height;

  /// widget `child`
  final Widget child;

  /// [AnimationController] used in the [SideMenuAnimation]
  final AnimationController controller;

  /// Animation [Curve]
  final Curve curve;

  /// Background `color`
  final Color color;

  /// Callback invoked `onTap`
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final _intervalGap = 1 / length;
    final _index = controller.status == AnimationStatus.reverse
        ? length - 1 - index
        : index;
    final _animation = Tween(begin: 0.0, end: 1.6).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          _intervalGap * _index,
          _intervalGap * (_index + 1),
          curve: curve,
        ),
      ),
    );
    return Positioned(
      left: position.isLeft ? 0 : null,
      right: position.isRight ? 0 : null,
      top: height * index,
      width: width,
      height: height,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(-_animation.value),
        alignment: position.isRight ? Alignment.topRight : Alignment.topLeft,
        child: Material(
          color: color,
          child: InkWell(
            onTap: () {
              controller.forward(from: 0.0);
              onTap();
            },
            child: child,
          ),
        ),
      ),
    );
  }
}
