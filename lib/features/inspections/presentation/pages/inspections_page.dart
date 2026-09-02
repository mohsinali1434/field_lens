import 'package:field_lens/app/router/app_routes.dart';
import 'package:field_lens/app/theme/app_icons.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/extensions/context_extensions.dart';
import 'package:field_lens/core/widgets/animated_fade_slide.dart';
import 'package:field_lens/core/widgets/app_card.dart';
import 'package:field_lens/core/widgets/app_page_header.dart';
import 'package:field_lens/core/widgets/app_status_chip.dart';
import 'package:field_lens/core/widgets/empty_state.dart';
import 'package:field_lens/core/widgets/error_view.dart';
import 'package:field_lens/core/widgets/loading_view.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspections_bloc.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspections_event.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspections_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Inspections list screen.
class InspectionsPage extends StatelessWidget {
  const InspectionsPage({super.key});

  Future<void> _openNewInspection(BuildContext context) async {
    final created = await context.push<bool>(AppRoutes.newInspection);
    if (created == true && context.mounted) {
      context.read<InspectionsBloc>().add(const InspectionsRefreshed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InspectionsBloc, InspectionsState>(
      builder: (BuildContext context, InspectionsState state) {
        return Scaffold(
          body: RefreshIndicator(
              onRefresh: () async {
                context.read<InspectionsBloc>().add(const InspectionsRefreshed());
                await context.read<InspectionsBloc>().stream.firstWhere(
                  (InspectionsState next) => next is! InspectionsLoading,
                );
              },
              child: switch (state) {
                InspectionsInitial() || InspectionsLoading() => ListView(
                  children: const <Widget>[
                    AppPageHeader(
                      title: 'Inspections',
                      subtitle: 'Manage your field inspections',
                      compact: true,
                    ),
                    SizedBox(height: 120),
                    LoadingView(message: 'Loading inspections...'),
                  ],
                ),
                InspectionsFailure(:final message) => ListView(
                  children: <Widget>[
                    const AppPageHeader(
                      title: 'Inspections',
                      subtitle: 'Manage your field inspections',
                      compact: true,
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.5,
                      child: ErrorView(
                        message: message,
                        onRetry: () => context.read<InspectionsBloc>().add(
                          const InspectionsRefreshed(),
                        ),
                      ),
                    ),
                  ],
                ),
                InspectionsEmpty() => ListView(
                  children: <Widget>[
                    const AppPageHeader(
                      title: 'Inspections',
                      subtitle: 'Manage your field inspections',
                      compact: true,
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.45,
                      child: EmptyState(
                        title: 'No inspections yet',
                        message:
                            'Create an inspection to begin documenting field conditions.',
                        icon: AppIcons.inspections,
                        actionLabel: 'New Inspection',
                        onAction: () => _openNewInspection(context),
                      ),
                    ),
                  ],
                ),
                InspectionsLoaded(:final inspections) => ListView.separated(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                  itemCount: inspections.length + 1,
                  separatorBuilder: (_, int index) {
                    if (index == 0) return const SizedBox.shrink();
                    return const SizedBox(height: AppSpacing.sm);
                  },
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: AnimatedFadeSlide(
                          child: AppPageHeader(
                            title: 'Inspections',
                            subtitle: 'Manage your field inspections',
                            compact: true,
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: AnimatedFadeSlide(
                        index: index,
                        child: _InspectionListTile(
                          inspection: inspections[index - 1],
                        ),
                      ),
                    );
                  },
                ),
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _openNewInspection(context),
              icon: const Icon(AppIcons.add),
              label: const Text('New Inspection'),
            ),
          );
      },
    );
  }
}

class _InspectionListTile extends StatelessWidget {
  const _InspectionListTile({required this.inspection});

  final InspectionEntity inspection;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat.yMMMd().format(inspection.updatedAt.toLocal());

    return AppCard(
      elevated: true,
      onTap: () => context.push(AppRoutes.inspectionDetailPath(inspection.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  inspection.title,
                  style: context.textTheme.titleMedium,
                ),
              ),
              AppStatusChip.inspection(inspection.status),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            inspection.siteName,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Icon(
                Icons.business_rounded,
                size: 14,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  inspection.clientName,
                  style: context.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                dateLabel,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
