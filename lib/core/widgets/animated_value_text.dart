import 'package:field_lens/core/animations/app_animations.dart';
import 'package:material_ui/material_ui.dart';

/// Animates text changes with a short fade and slide.
class AnimatedValueText extends StatelessWidget {
  const AnimatedValueText({
    required this.value,
    required this.style,
    super.key,
  });

  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppAnimations.normal,
      switchInCurve: AppAnimations.standard,
      switchOutCurve: AppAnimations.exit,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.25),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Text(
        value,
        key: ValueKey<String>(value),
        style: style,
      ),
    );
  }
}
