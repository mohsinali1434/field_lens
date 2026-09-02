import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:field_lens/app/router/app_routes.dart';
import 'package:field_lens/app/theme/app_colors.dart';
import 'package:field_lens/app/theme/app_icons.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/constants/app_constants.dart';
import 'package:field_lens/core/extensions/context_extensions.dart';
import 'package:field_lens/core/widgets/animated_fade_slide.dart';
import 'package:field_lens/core/widgets/app_button.dart';
import 'package:field_lens/core/widgets/app_card.dart';
import 'package:field_lens/core/widgets/app_page_header.dart';
import 'package:field_lens/core/widgets/app_section_header.dart';
import 'package:field_lens/core/widgets/app_stat_card.dart';
import 'package:field_lens/core/widgets/app_status_chip.dart';
import 'package:field_lens/core/widgets/empty_state.dart';
import 'package:field_lens/core/widgets/error_view.dart';
import 'package:field_lens/core/widgets/loading_view.dart';
import 'package:field_lens/features/dashboard/domain/models/dashboard_overview.dart';
import 'package:field_lens/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:field_lens/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:field_lens/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Dashboard home screen with live statistics and recent inspections.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>(
      create: (_) => sl<DashboardBloc>()..add(const DashboardStarted()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _openNewInspection(BuildContext context) async {
    final created = await context.push<bool>(AppRoutes.newInspection);
    if (created == true && context.mounted) {
      context.read<DashboardBloc>().add(const DashboardRefreshed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (BuildContext context, DashboardState state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(const DashboardRefreshed());
              await context.read<DashboardBloc>().stream.firstWhere(
                (DashboardState next) => next is! DashboardLoading,
              );
            },
            child: switch (state) {
              DashboardInitial() || DashboardLoading() => const CustomScrollView(
                slivers: <Widget>[
                  SliverFillRemaining(
                    child: LoadingView(message: 'Loading dashboard...'),
                  ),
                ],
              ),
              DashboardFailure(:final message) => CustomScrollView(
                slivers: <Widget>[
                  SliverFillRemaining(
                    child: ErrorView(
                      message: message,
                      onRetry: () => context.read<DashboardBloc>().add(
                        const DashboardRefreshed(),
                      ),
                    ),
                  ),
                ],
              ),
              DashboardEmpty(:final overview) => _DashboardContent(
                overview: overview,
                greeting: _greeting(),
                onNewInspection: () => _openNewInspection(context),
                showEmptyRecent: true,
              ),
              DashboardLoaded(:final overview) => _DashboardContent(
                overview: overview,
                greeting: _greeting(),
                onNewInspection: () => _openNewInspection(context),
                showEmptyRecent: false,
              ),
            },
          );
        },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.overview,
    required this.greeting,
    required this.onNewInspection,
    required this.showEmptyRecent,
  });

  final DashboardOverview overview;
  final String greeting;
  final VoidCallback onNewInspection;
  final bool showEmptyRecent;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: AnimatedFadeSlide(
            child: AppPageHeader(
              title: greeting,
              subtitle: AppConstants.appTagline,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AnimatedFadeSlide(
                  index: 1,
                  child: const AppSectionHeader(title: "Today's overview"),
                ),
                _StatGrid(overview: overview),
                const SizedBox(height: AppSpacing.lg),
                AnimatedFadeSlide(
                  index: 2,
                  child: const AppSectionHeader(title: 'Quick actions'),
                ),
                _QuickActions(
                  overview: overview,
                  onNewInspection: onNewInspection,
                ),
                const SizedBox(height: AppSpacing.lg),
                AnimatedFadeSlide(
                  index: 3,
                  child: const AppSectionHeader(title: 'Recent inspections'),
                ),
              ],
            ),
          ),
        ),
        if (showEmptyRecent)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              title: 'No inspections yet',
              message: 'Start your first field inspection.',
              icon: AppIcons.inspections,
              actionLabel: 'New Inspection',
              onAction: onNewInspection,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            sliver: SliverList.separated(
              itemCount: overview.recentInspections.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (BuildContext context, int index) {
                return AnimatedFadeSlide(
                  index: index + 4,
                  child: _RecentInspectionCard(
                    item: overview.recentInspections[index],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.overview,
    required this.onNewInspection,
  });

  final DashboardOverview overview;
  final VoidCallback onNewInspection;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AnimatedFadeSlide(
          index: 3,
          child: AppButton(
            label: 'New Inspection',
            icon: AppIcons.add,
            expand: true,
            onPressed: onNewInspection,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: <Widget>[
            Expanded(
              child: AnimatedFadeSlide(
                index: 4,
                child: AppButton(
                  label: 'Continue',
                  variant: AppButtonVariant.outlined,
                  icon: AppIcons.inspections,
                  onPressed: overview.recentInspections.isEmpty
                      ? null
                      : () => context.go(AppRoutes.inspections),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AnimatedFadeSlide(
                index: 5,
                child: AppButton(
                  label: 'Reports',
                  variant: AppButtonVariant.outlined,
                  icon: AppIcons.reports,
                  onPressed: () => context.go(AppRoutes.reports),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.overview});

  final DashboardOverview overview;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final cards = <Widget>[
          AnimatedFadeSlide(
            index: 2,
            child: AppStatCard(
              label: 'Active Inspections',
              value: '${overview.activeInspections}',
              color: AppColors.info,
              icon: Icons.assignment_outlined,
            ),
          ),
          AnimatedFadeSlide(
            index: 3,
            child: AppStatCard(
              label: 'Completed',
              value: '${overview.completedInspections}',
              color: AppColors.success,
              icon: Icons.check_circle_outline_rounded,
            ),
          ),
          AnimatedFadeSlide(
            index: 4,
            child: AppStatCard(
              label: 'Pending Reports',
              value: '${overview.pendingReports}',
              color: AppColors.warning,
              icon: Icons.description_outlined,
            ),
          ),
        ];

        if (constraints.maxWidth >= 500) {
          return Row(
            children: <Widget>[
              for (var i = 0; i < cards.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }

        return Column(
          children: <Widget>[
            for (var i = 0; i < cards.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(height: AppSpacing.sm),
              cards[i],
            ],
          ],
        );
      },
    );
  }
}

class _RecentInspectionCard extends StatelessWidget {
  const _RecentInspectionCard({required this.item});

  final RecentInspectionItem item;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat.yMMMd().format(item.date.toLocal());

    return AppCard(
      elevated: true,
      onTap: () => context.push(AppRoutes.inspectionDetailPath(item.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(item.title, style: context.textTheme.titleMedium),
              ),
              AppStatusChip.inspection(item.status),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.location,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(dateLabel, style: context.textTheme.bodySmall),
              const Spacer(),
              Text(
                '${item.observationCount} obs',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  child: Text(
                    '${item.completionPercent}%',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
