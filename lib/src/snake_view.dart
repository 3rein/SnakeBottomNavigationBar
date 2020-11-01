import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/src/theming/snake_bottom_bar_theme.dart';
import 'package:flutter_snake_navigationbar/src/theming/snake_shape.dart';

import 'selection_notifier.dart';

class SnakeView extends StatefulWidget {
  final int itemsCount;
  final SnakeShape shape;
  final double widgetEdgePadding;
  final SelectionNotifier notifier;
  final Duration animationDuration;
  final Duration delayTransition;
  final Curve snakeCurve;
  final double circlePadding;

  SnakeView({
    @required this.itemsCount,
    @required this.shape,
    @required this.widgetEdgePadding,
    @required this.notifier,
    this.animationDuration = const Duration(milliseconds: 200),
    this.delayTransition = const Duration(milliseconds: 50),
    this.snakeCurve = Curves.easeInOut,
    this.circlePadding = 4,
  });

  @override
  _SnakeViewState createState() => _SnakeViewState();
}

class _SnakeViewState extends State<SnakeView> {
  double left = 0;
  int snakeSize = 1;
  int currentIndex;
  Orientation orientation;
  double oneItemWidth;
  double prevItemWidth;

  @override
  Widget build(BuildContext context) {
    oneItemWidth =
        (MediaQuery.of(context).size.width - widget.widgetEdgePadding) /
            widget.itemsCount;

    widget.notifier.addListener(() {
      int newSnakeSize;
      if (widget.notifier.lastIndex < widget.notifier.currentIndex) {
        //region going right
        newSnakeSize =
            widget.notifier.currentIndex + 1 - widget.notifier.lastIndex;
        setState(() => snakeSize = newSnakeSize);
        Future.delayed(
            widget.animationDuration + widget.delayTransition,
            () => setState(() {
                  snakeSize = 1;
                  left = oneItemWidth * widget.notifier.currentIndex;
                }));
        //endregion
      } else if (widget.notifier.lastIndex > widget.notifier.currentIndex) {
        //region going left
        newSnakeSize =
            (widget.notifier.currentIndex - widget.notifier.lastIndex).abs();
        setState(() {
          left = oneItemWidth * widget.notifier.currentIndex;
          snakeSize = newSnakeSize + 1;
        });
        Future.delayed(widget.animationDuration + widget.delayTransition,
            () => setState(() => snakeSize = 1));
        //endregion
      } else {
        //the same place
        newSnakeSize = snakeSize;
      }
      currentIndex = widget.notifier.currentIndex;
    });

    if (currentIndex == null ||
        currentIndex != widget.notifier.currentIndex ||
        orientation != MediaQuery.of(context).orientation ||
        prevItemWidth != oneItemWidth) {
      left = oneItemWidth * widget.notifier.currentIndex;
      currentIndex = widget.notifier.currentIndex;
      orientation = MediaQuery.of(context).orientation;
      prevItemWidth = oneItemWidth;
    }

    EdgeInsets viewPadding = widget.shape.type == SnakeShapeType.circle ||
            widget.shape.centered
        ? EdgeInsets.symmetric(
            vertical: ((kBottomNavigationBarHeight - widget.shape.height) / 2) +
                widget.circlePadding,
            horizontal: (oneItemWidth -
                    (widget.shape.height - widget.circlePadding * 2)) /
                2,
          )
        : (widget.shape.height != kBottomNavigationBarHeight &&
                widget.shape.type != SnakeShapeType.indicator
            ? EdgeInsets.symmetric(
                vertical:
                    (kBottomNavigationBarHeight - widget.shape.height) / 2,
              )
            : EdgeInsets.zero);

    double snakeViewWidth =
        widget.shape.type == SnakeShapeType.circle || widget.shape.centered
            ? oneItemWidth * snakeSize - (viewPadding.left + viewPadding.right)
            : oneItemWidth * snakeSize;

    return AnimatedPositioned(
      left: left,
      duration: widget.animationDuration,
      curve: widget.snakeCurve,
      child: AnimatedPadding(
        duration: widget.animationDuration,
        padding: viewPadding,
        child: AnimatedContainer(
          curve: widget.snakeCurve,
          duration: widget.animationDuration,
          width: snakeViewWidth,
          height: _snakeViewHeight(),
          child: Material(
            shape: _snakeShape(),
            clipBehavior: Clip.antiAlias,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: SnakeBottomBarTheme.of(context).snakeGradient,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _snakeViewHeight() {
    var themeHeight = widget.shape.height;
    switch (widget.shape.type) {
      case SnakeShapeType.circle:
        return themeHeight - widget.circlePadding * 2;
        break;
      case SnakeShapeType.rectangle:
      case SnakeShapeType.indicator:
        return themeHeight;
        break;
      case SnakeShapeType.custom:
        return widget.shape.centered
            ? themeHeight - widget.circlePadding * 2
            : themeHeight;
        break;
    }
    return -1;
  }

  ShapeBorder _snakeShape() {
    switch (widget.shape.type) {
      case SnakeShapeType.circle:
        return _getRoundShape(_snakeViewHeight() / 2);
        break;
      default:
        return widget.shape.shape;
        break;
    }
  }

  ShapeBorder _getRoundShape(double radius) => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      );
}
