import 'package:field_lens/core/animations/app_animations.dart';
import 'package:material_ui/material_ui.dart';

/// Scales down slightly while pressed for tactile tap feedback.
class AnimatedPressable extends StatefulWidget {
  const AnimatedPressable({
    required this.child,
    super.key,
    this.pressedScale = 0.90,
  });

  final Widget child;
  final double pressedScale;

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
      value: 1,
    );
    _scale = Tween<double>(begin: widget.pressedScale, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.standard),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _release() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _controller.reverse(),
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
