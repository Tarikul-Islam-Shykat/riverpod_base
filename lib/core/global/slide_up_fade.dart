import 'package:flutter/material.dart';

/// A widget that slides its [child] up from below while fading it in.
///
/// Usage:
/// ```dart
/// SlideUpFade(
///   delay: const Duration(milliseconds: 200),
///   child: MyWidget(),
/// )
/// ```
class SlideUpFade extends StatefulWidget {
  const SlideUpFade({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 450),
    this.offsetY = 40.0, // how many pixels to start from below
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;
  final Curve curve;

  @override
  State<SlideUpFade> createState() => _SlideUpFadeState();
}

class _SlideUpFadeState extends State<SlideUpFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _slide = Tween<Offset>(
      begin: Offset(0, widget.offsetY / 100), // normalised — FractionalOffset
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Wait for the delay, then play
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}