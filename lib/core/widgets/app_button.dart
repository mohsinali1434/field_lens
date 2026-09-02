import 'package:field_lens/app/theme/app_radius.dart';
import 'package:field_lens/app/theme/app_shadows.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/extensions/context_extensions.dart';
import 'package:material_ui/material_ui.dart';

enum AppButtonVariant { primary, secondary, outlined, text, danger }

/// Reusable button with consistent styling.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.primary
                  ? context.colors.onPrimary
                  : context.colors.primary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 20),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(label),
            ],
          );

    final button = switch (variant) {
      AppButtonVariant.primary => _PrimaryButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
      AppButtonVariant.secondary => FilledButton.tonal(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
      AppButtonVariant.danger => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.error,
          foregroundColor: context.colors.onError,
        ),
        child: child,
      ),
    };

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: context.appTheme.heroGradient,
        borderRadius: AppRadius.lgRadius,
        boxShadow: onPressed == null
            ? null
            : AppShadows.glow(context.appTheme.glow),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.lgRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: DefaultTextStyle(
              style: context.textTheme.labelLarge!.copyWith(
                color: Colors.white,
              ),
              child: IconTheme(
                data: const IconThemeData(color: Colors.white, size: 20),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
