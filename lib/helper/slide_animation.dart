import 'package:flutter/material.dart';

enum SlideDirection{ fromTop, fromLeft,fromRight,fromBottom}

class SlideAnimation extends StatefulWidget {
  final int? position;
  final int? itemCount;
  final Widget? child;
  final SlideDirection? slideDirection;
  final AnimationController? animationController;
  final Curve? curves;

  const SlideAnimation({Key? key, this.position, this.itemCount, this.slideDirection, this.animationController, this.child, this.curves}) : super(key: key);

  @override
  _SlideAnimationState createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<SlideAnimation> {


  @override
  Widget build(BuildContext context) {
    var xTranslation=0.0,yTranslation=0.0;
    var _animation=Tween(
        begin: 0.0,end: 1.0
    ).animate(CurvedAnimation(curve: Interval((1/widget.itemCount!) * widget.position!,1.0,curve: widget.curves!), parent: widget.animationController!));
    //Interval((1/widget.itemCount) * widget.position,1.0,curve: widget.curves)
    widget.animationController!.forward();

    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (context, child){
        if (widget.slideDirection == SlideDirection.fromTop) {
          // this will animate items from top with fade transition
          yTranslation = -50 * (1.0 - _animation.value);
        } else if (widget.slideDirection == SlideDirection.fromBottom) {
          // this will animate items from bottom with fade transition
          yTranslation = 50 * (1.0 - _animation.value);
        } else if (widget.slideDirection == SlideDirection.fromRight) {
          // this will animate items from right with fade transition
          xTranslation = 400 * (1.0 - _animation.value);
        } else {
          // this will animate items from left with fade transition
          xTranslation = -400 * (1.0 - _animation.value);
        }

        return FadeTransition(
          opacity: _animation,
          child: Transform(
            child: widget.child,
            // based on our slide direction and x and y values the widget will animate
            transform: Matrix4.translationValues(xTranslation, yTranslation, 0.0),
          ),
        );
      },
    );
  }
}
