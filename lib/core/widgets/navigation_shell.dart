import 'package:field_lens/app/theme/app_icons.dart';
import 'package:field_lens/app/theme/app_radius.dart';
import 'package:field_lens/app/theme/app_shadows.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/extensions/context_extensions.dart';
import 'package:field_lens/core/widgets/app_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

/// Root navigation shell with floating bottom navigation bar.
class NavigationShell extends StatelessWidget {
  const NavigationShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: EdgeInsets.zero,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.appTheme.navBackground,
            borderRadius: AppRadius.xlRadius,
            border: Border.all(color: context.appTheme.cardBorder),
            boxShadow: AppShadows.navBar(context.colors.shadow),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.xlRadius,
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 68,
              destinations: const <NavigationDestination>[
                NavigationDestination(
                  icon: Icon(AppIcons.home),
                  selectedIcon: Icon(AppIcons.homeFilled),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(AppIcons.inspections),
                  selectedIcon: Icon(AppIcons.inspectionsFilled),
                  label: 'Inspections',
                ),
                NavigationDestination(
                  icon: Icon(AppIcons.reports),
                  selectedIcon: Icon(AppIcons.reportsFilled),
                  label: 'Reports',
                ),
                NavigationDestination(
                  icon: Icon(AppIcons.search),
                  selectedIcon: Icon(AppIcons.search),
                  label: 'Search',
                ),
                NavigationDestination(
                  icon: Icon(AppIcons.settings),
                  selectedIcon: Icon(AppIcons.settingsFilled),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
