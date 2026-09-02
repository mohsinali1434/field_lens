import 'dart:async';

import 'package:field_lens/core/animations/app_animations.dart';
import 'package:material_ui/material_ui.dart';

/// Fades and slides a child in with optional stagger by [index].
class AnimatedFadeSlide extends StatefulWidget {
  const AnimatedFadeSlide({
    required this.child,
    super.key,
    this.index = 0,
    this.offsetY = 16,
  });

  final Widget child;
  final int index;
  final double offsetY;

  @override
  State<AnimatedFadeSlide> createState() => _AnimatedFadeSlideState();
}

class _AnimatedFadeSlideState extends State<AnimatedFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;
  Timer? _staggerTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.standard,
    );
    _offset = Tween<Offset>(
      begin: Offset(0, widget.offsetY / 100),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.standard),
    );

    final delay = AppAnimations.stagger * widget.index;
    if (delay == Duration.zero) {
      unawaited(_controller.forward());
    } else {
      _staggerTimer = Timer(delay, () {
        if (mounted) {
          unawaited(_controller.forward());
        }
      });
    }
  }

  @override
  void dispose() {
    _staggerTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
