import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// Base scaffold with consistent padding and optional app bar.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    super.key,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showBackButton = false,
    this.centerTitle = false,
    this.padding,
  });

  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showBackButton;
  final bool centerTitle;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: bottomNavigationBar != null,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              centerTitle: centerTitle,
              automaticallyImplyLeading: showBackButton,
              actions: actions,
            ),
      body: SafeArea(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
