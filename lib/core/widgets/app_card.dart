import 'package:field_lens/app/theme/app_radius.dart';
import 'package:field_lens/app/theme/app_shadows.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/extensions/context_extensions.dart';
import 'package:field_lens/core/widgets/animated_pressable.dart';
import 'package:material_ui/material_ui.dart';

/// Reusable card with consistent elevation and padding.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.elevated = false,
    this.accentColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool elevated;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);

    final decoration = BoxDecoration(
      color: context.colors.surface,
      borderRadius: AppRadius.lgRadius,
      border: Border.all(color: context.appTheme.cardBorder),
      boxShadow: elevated ? AppShadows.card(context.colors.shadow) : null,
    );

    Widget card = DecoratedBox(
      decoration: decoration,
      child: ClipRRect(
        borderRadius: AppRadius.lgRadius,
        child: accentColor == null
            ? _buildInteractive(context, content)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(height: 3, color: accentColor),
                  _buildInteractive(context, content),
                ],
              ),
      ),
    );

    if (onTap != null) {
      card = AnimatedPressable(child: card);
    }

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }
    return card;
  }

  Widget _buildInteractive(BuildContext context, Widget content) {
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgRadius,
        splashColor: context.colors.primary.withValues(alpha: 0.08),
        highlightColor: context.colors.primary.withValues(alpha: 0.04),
        child: content,
      ),
    );
  }
}
