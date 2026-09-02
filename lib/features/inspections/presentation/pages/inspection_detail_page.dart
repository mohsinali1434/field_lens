import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:field_lens/app/router/app_routes.dart';
import 'package:field_lens/app/theme/app_icons.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/extensions/context_extensions.dart';
import 'package:field_lens/core/services/audio_player_service.dart';
import 'package:field_lens/core/services/checklist_setup_service.dart';
import 'package:field_lens/core/services/intelligence_service.dart';
import 'package:field_lens/core/services/pdf_report_service.dart';
import 'package:field_lens/core/widgets/app_button.dart';
import 'package:field_lens/core/widgets/app_card.dart';
import 'package:field_lens/core/widgets/empty_state.dart';
import 'package:field_lens/core/widgets/error_view.dart';
import 'package:field_lens/core/widgets/loading_view.dart';
import 'package:field_lens/core/widgets/app_status_chip.dart';
import 'package:field_lens/features/checklists/domain/entities/checklist_entities.dart';
import 'package:field_lens/features/checklists/domain/entities/checklist_item_status.dart';
import 'package:field_lens/features/checklists/domain/repositories/checklist_repository.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_type.dart';
import 'package:field_lens/features/inspections/domain/models/inspection_workspace.dart';
import 'package:field_lens/features/inspections/domain/repositories/timeline_repository.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspection_detail_bloc.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspection_detail_event.dart';
import 'package:field_lens/features/inspections/presentation/bloc/inspection_detail_state.dart';
import 'package:field_lens/features/media/domain/entities/media_entity.dart';
import 'package:field_lens/features/media/domain/entities/media_type.dart';
import 'package:field_lens/features/observations/domain/entities/observation_entity.dart';
import 'package:field_lens/features/observations/domain/entities/observation_enums.dart';
import 'package:field_lens/features/reports/domain/entities/report_entity.dart';
import 'package:field_lens/features/reports/domain/entities/report_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:uuid/uuid.dart';

/// Tabbed inspection workspace with observations, media, and reports.
class InspectionDetailPage extends StatelessWidget {
  const InspectionDetailPage({required this.inspectionId, super.key});

  final String inspectionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InspectionDetailBloc>(
      create: (_) =>
          sl<InspectionDetailBloc>()
            ..add(InspectionDetailStarted(inspectionId)),
      child: _InspectionDetailView(inspectionId: inspectionId),
    );
  }
}

class _InspectionDetailView extends StatelessWidget {
  const _InspectionDetailView({required this.inspectionId});

  final String inspectionId;

  Future<void> _openRoute(BuildContext context, String route) async {
    final saved = await context.push<bool>(route);
    if (saved == true && context.mounted) {
      context.read<InspectionDetailBloc>().add(
        const InspectionDetailRefreshed(),
      );
    }
  }

  Future<void> _openObservationForm(BuildContext context) async {
    await _openRoute(context, AppRoutes.newObservationPath(inspectionId));
  }

  Future<void> _openObservationEdit(
    BuildContext context,
    String observationId,
  ) async {
    await _openRoute(
      context,
      AppRoutes.editObservationPath(inspectionId, observationId),
    );
  }

  void _showStatusMenu(BuildContext context, InspectionWorkspace workspace) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Update inspection status',
                  style: context.textTheme.titleMedium,
                ),
              ),
              for (final InspectionStatus status in InspectionStatus.values)
                if (status != InspectionStatus.archived)
                  ListTile(
                    leading: AppStatusChip.inspection(status),
                    title: Text(_inspectionStatusLabel(status)),
                    trailing: workspace.inspection.status == status
                        ? Icon(Icons.check_rounded, color: context.colors.primary)
                        : null,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.read<InspectionDetailBloc>().add(
                        InspectionStatusChanged(status.value),
                      );
                    },
                  ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.archive_outlined, color: context.colors.error),
                title: Text(
                  'Archive inspection',
                  style: TextStyle(color: context.colors.error),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.read<InspectionDetailBloc>().add(
                    const InspectionArchived(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static String _inspectionStatusLabel(InspectionStatus status) {
    return switch (status) {
      InspectionStatus.draft => 'Draft',
      InspectionStatus.inProgress => 'In Progress',
      InspectionStatus.completed => 'Completed',
      InspectionStatus.archived => 'Archived',
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InspectionDetailBloc, InspectionDetailState>(
      listener: (BuildContext context, InspectionDetailState state) {
        if (state is InspectionDetailFailure &&
            state.message == 'Inspection archived') {
          context.pop();
        }
      },
      child: DefaultTabController(
        length: 7,
        child: BlocBuilder<InspectionDetailBloc, InspectionDetailState>(
          builder: (BuildContext context, InspectionDetailState state) {
            return Scaffold(
              appBar: AppBar(
                title: switch (state) {
                  InspectionDetailLoaded(:final workspace) => Text(
                    workspace.inspection.title,
                  ),
                  _ => const Text('Inspection'),
                },
                actions: switch (state) {
                  InspectionDetailLoaded(:final workspace) => <Widget>[
                    IconButton(
                      tooltip: 'Update status',
                      icon: const Icon(Icons.more_vert_rounded),
                      onPressed: () => _showStatusMenu(context, workspace),
                    ),
                  ],
                  _ => null,
                },
                bottom: const TabBar(
                  isScrollable: true,
                  tabs: <Widget>[
                    Tab(text: 'Overview'),
                    Tab(text: 'Observations'),
                    Tab(text: 'Media'),
                    Tab(text: 'Checklist'),
                    Tab(text: 'Notes'),
                    Tab(text: 'Timeline'),
                    Tab(text: 'Report'),
                  ],
                ),
              ),
              body: switch (state) {
                InspectionDetailInitial() || InspectionDetailLoading() =>
                  LoadingView(message: 'Loading inspection...'),
                InspectionDetailFailure(:final message) => ErrorView(
                  message: message,
                  onRetry: () => context.read<InspectionDetailBloc>().add(
                    const InspectionDetailRefreshed(),
                  ),
                ),
                InspectionDetailLoaded(:final workspace) => Column(
                  children: <Widget>[
                    _InspectionHeader(
                      workspace: workspace,
                      onLocationTap: () => _openRoute(
                        context,
                        AppRoutes.inspectionLocationPath(inspectionId),
                      ),
                    ),
                    _QuickActionsRow(
                      onObservation: () => _openObservationForm(context),
                      onPhoto: () => _openRoute(
                        context,
                        AppRoutes.capturePhotoPath(inspectionId),
                      ),
                      onVoice: () => _openRoute(
                        context,
                        AppRoutes.voiceNotePath(inspectionId),
                      ),
                      onNote: () => _openRoute(
                        context,
                        AppRoutes.inspectionNotePath(inspectionId),
                      ),
                      onLocation: () => _openRoute(
                        context,
                        AppRoutes.inspectionLocationPath(inspectionId),
                      ),
                      onChecklist: () {
                        DefaultTabController.of(context).animateTo(3);
                      },
                    ),
                    Expanded(
                      child: TabBarView(
                        children: <Widget>[
                          _OverviewTab(workspace: workspace),
                          _ObservationsTab(
                            workspace: workspace,
                            inspectionId: inspectionId,
                            onAdd: () => _openObservationForm(context),
                            onEdit: (String observationId) =>
                                _openObservationEdit(context, observationId),
                          ),
                          _MediaTab(
                            workspace: workspace,
                            onAddPhoto: () => _openRoute(
                              context,
                              AppRoutes.capturePhotoPath(inspectionId),
                            ),
                            onAddVoice: () => _openRoute(
                              context,
                              AppRoutes.voiceNotePath(inspectionId),
                            ),
                          ),
                          _ChecklistTab(
                            workspace: workspace,
                            onUpdated: () => context
                                .read<InspectionDetailBloc>()
                                .add(const InspectionDetailRefreshed()),
                          ),
                          _NotesTab(
                            workspace: workspace,
                            onEdit: () => _openRoute(
                              context,
                              AppRoutes.inspectionNotePath(inspectionId),
                            ),
                          ),
                          _TimelineTab(workspace: workspace),
                          _ReportTab(
                            workspace: workspace,
                            onGenerated: () => context
                                .read<InspectionDetailBloc>()
                                .add(const InspectionDetailRefreshed()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              },
            );
          },
        ),
      ),
    );
  }
}

class _InspectionHeader extends StatelessWidget {
  const _InspectionHeader({
    required this.workspace,
    required this.onLocationTap,
  });

  final InspectionWorkspace workspace;
  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context) {
    final inspection = workspace.inspection;
    final dateLabel = DateFormat.yMMMd().format(inspection.updatedAt.toLocal());
    final location = inspection.address?.isNotEmpty == true
        ? inspection.address!
        : inspection.siteName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              AppStatusChip.inspection(inspection.status),
              InkWell(
                onTap: onLocationTap,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        AppIcons.location,
                        size: 16,
                        color: context.colors.primary,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        location,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text('· $dateLabel', style: context.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '${inspection.clientName} · ${inspection.siteName}',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.onObservation,
    required this.onPhoto,
    required this.onVoice,
    required this.onNote,
    required this.onLocation,
    required this.onChecklist,
  });

  final VoidCallback onObservation;
  final VoidCallback onPhoto;
  final VoidCallback onVoice;
  final VoidCallback onNote;
  final VoidCallback onLocation;
  final VoidCallback onChecklist;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          _QuickActionButton(
            icon: AppIcons.add,
            label: 'Observation',
            onPressed: onObservation,
          ),
          _QuickActionButton(
            icon: AppIcons.camera,
            label: 'Photo',
            onPressed: onPhoto,
          ),
          _QuickActionButton(
            icon: AppIcons.microphone,
            label: 'Voice',
            onPressed: onVoice,
          ),
          _QuickActionButton(
            icon: AppIcons.note,
            label: 'Note',
            onPressed: onNote,
          ),
          _QuickActionButton(
            icon: AppIcons.location,
            label: 'Location',
            onPressed: onLocation,
          ),
          _QuickActionButton(
            icon: AppIcons.checklist,
            label: 'Checklist',
            onPressed: onChecklist,
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Material(
        color: context.colors.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 18, color: context.colors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.workspace});

  final InspectionWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    final inspection = workspace.inspection;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: <Widget>[
        AppCard(
          elevated: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Summary', style: context.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                inspection.description.isEmpty
                    ? 'No description provided.'
                    : inspection.description,
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          elevated: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Counts', style: context.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              _StatRow(
                label: 'Observations',
                value: '${workspace.observations.length}',
              ),
              _StatRow(label: 'Media', value: '${workspace.media.length}'),
              _StatRow(
                label: 'Checklist items',
                value: '${workspace.checklistResults.length}',
              ),
              _StatRow(
                label: 'Timeline events',
                value: '${workspace.timeline.length}',
              ),
              _StatRow(label: 'Reports', value: '${workspace.reports.length}'),
            ],
          ),
        ),
        if (inspection.weatherSummary?.isNotEmpty == true) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          AppCard(
            elevated: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Weather', style: context.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  inspection.weatherSummary!,
                  style: context.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: context.textTheme.bodyMedium),
          Text(value, style: context.textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _ObservationsTab extends StatelessWidget {
  const _ObservationsTab({
    required this.workspace,
    required this.inspectionId,
    required this.onAdd,
    required this.onEdit,
  });

  final InspectionWorkspace workspace;
  final String inspectionId;
  final VoidCallback onAdd;
  final ValueChanged<String> onEdit;

  @override
  Widget build(BuildContext context) {
    if (workspace.observations.isEmpty) {
      return EmptyState(
        title: 'No observations',
        message: 'Document field conditions as you inspect.',
        icon: AppIcons.inspections,
        actionLabel: 'Add Observation',
        onAction: onAdd,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: workspace.observations.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (BuildContext context, int index) {
        return _ObservationCard(
          observation: workspace.observations[index],
          onTap: () => onEdit(workspace.observations[index].id),
        );
      },
    );
  }
}

class _ObservationCard extends StatelessWidget {
  const _ObservationCard({required this.observation, required this.onTap});

  final ObservationEntity observation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevated: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  observation.title,
                  style: context.textTheme.titleSmall,
                ),
              ),
              AppStatusChip.severity(observation.severity.value),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '${_categoryLabel(observation.category)} · '
            '${_statusLabel(observation.status)}',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
          if (observation.description.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(observation.description, style: context.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  static String _categoryLabel(ObservationCategory category) {
    return category.value[0].toUpperCase() + category.value.substring(1);
  }

  static String _statusLabel(ObservationStatus status) {
    return switch (status) {
      ObservationStatus.open => 'Open',
      ObservationStatus.inProgress => 'In Progress',
      ObservationStatus.resolved => 'Resolved',
      ObservationStatus.ignored => 'Ignored',
    };
  }
}

class _MediaTab extends StatelessWidget {
  const _MediaTab({
    required this.workspace,
    required this.onAddPhoto,
    required this.onAddVoice,
  });

  final InspectionWorkspace workspace;
  final VoidCallback onAddPhoto;
  final VoidCallback onAddVoice;

  @override
  Widget build(BuildContext context) {
    if (workspace.media.isEmpty) {
      return EmptyState(
        title: 'No media',
        message: 'Photos, audio, and documents appear here.',
        icon: AppIcons.camera,
        actionLabel: 'Add Photo',
        onAction: onAddPhoto,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: workspace.media.length + 1,
      separatorBuilder: (_, int index) {
        if (index == 0) return const SizedBox(height: AppSpacing.sm);
        return const SizedBox(height: AppSpacing.sm);
      },
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Row(
            children: <Widget>[
              Expanded(
                child: AppButton(
                  label: 'Add Photo',
                  icon: AppIcons.camera,
                  variant: AppButtonVariant.outlined,
                  onPressed: onAddPhoto,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'Add Voice',
                  icon: AppIcons.microphone,
                  variant: AppButtonVariant.outlined,
                  onPressed: onAddVoice,
                ),
              ),
            ],
          );
        }
        return _MediaCard(media: workspace.media[index - 1]);
      },
    );
  }
}

class _MediaCard extends StatelessWidget {
  const _MediaCard({required this.media});

  final MediaEntity media;

  Future<void> _open(BuildContext context) async {
    if (media.type == MediaType.image) {
      if (!File(media.filePath).existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image file not found.')),
        );
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: InteractiveViewer(
              child: Image.file(File(media.filePath), fit: BoxFit.contain),
            ),
          );
        },
      );
      return;
    }

    if (media.type == MediaType.audio) {
      final result = await sl<AudioPlayerService>().play(media.filePath);
      if (!context.mounted) return;
      result.fold(
        onSuccess: (_) {},
        onFailure: (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = switch (media.type) {
      MediaType.image => AppIcons.camera,
      MediaType.audio => AppIcons.microphone,
      MediaType.document => AppIcons.reports,
    };

    return AppCard(
      elevated: true,
      onTap: () => _open(context),
      child: Row(
        children: <Widget>[
          Icon(icon, color: context.colors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _typeLabel(media.type),
                  style: context.textTheme.titleSmall,
                ),
                Text(
                  p.basename(media.filePath),
                  style: context.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (media.metadata?.isNotEmpty == true) ...<Widget>[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    media.metadata!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            media.type == MediaType.audio
                ? Icons.play_circle_outline_rounded
                : Icons.open_in_new_rounded,
            color: context.colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  static String _typeLabel(MediaType type) {
    return switch (type) {
      MediaType.image => 'Photo',
      MediaType.audio => 'Audio',
      MediaType.document => 'Document',
    };
  }
}

class _ChecklistTab extends StatefulWidget {
  const _ChecklistTab({required this.workspace, required this.onUpdated});

  final InspectionWorkspace workspace;
  final VoidCallback onUpdated;

  @override
  State<_ChecklistTab> createState() => _ChecklistTabState();
}

class _ChecklistTabState extends State<_ChecklistTab> {
  bool _isBusy = false;

  Future<void> _recordTimeline(String title, String description) async {
    await sl<TimelineRepository>().add(
      TimelineEventEntity(
        id: const Uuid().v4(),
        inspectionId: widget.workspace.inspection.id,
        eventType: TimelineEventType.other,
        title: title,
        description: description,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> _applyStandardChecklist() async {
    setState(() => _isBusy = true);
    final result = await sl<ChecklistSetupService>().attachDefaultChecklist(
      widget.workspace.inspection.id,
    );
    if (!mounted) return;

    result.fold(
      onSuccess: (int count) async {
        await _recordTimeline(
          'Checklist applied',
          '$count checklist items were added.',
        );
        setState(() => _isBusy = false);
        widget.onUpdated();
      },
      onFailure: (failure) {
        setState(() => _isBusy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  Future<void> _addCustomItem() async {
    final titleController = TextEditingController();
    final added = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add checklist item'),
          content: TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Item title',
              hintText: 'e.g. Roof condition',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (added != true || !mounted) {
      titleController.dispose();
      return;
    }

    setState(() => _isBusy = true);
    final result = await sl<ChecklistSetupService>().addCustomItem(
      inspectionId: widget.workspace.inspection.id,
      title: titleController.text,
    );
    titleController.dispose();
    if (!mounted) return;

    result.fold(
      onSuccess: (ChecklistResultEntity item) async {
        await _recordTimeline(
          'Checklist item added',
          'Added "${item.title}" to the checklist.',
        );
        setState(() => _isBusy = false);
        widget.onUpdated();
      },
      onFailure: (failure) {
        setState(() => _isBusy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isBusy) {
      return const LoadingView(message: 'Updating checklist...');
    }

    if (widget.workspace.checklistResults.isEmpty) {
      return Column(
        children: <Widget>[
          Expanded(
            child: EmptyState(
              title: 'No checklist yet',
              message:
                  'Apply the standard inspection checklist or add your own items.',
              icon: AppIcons.checklist,
              actionLabel: 'Apply Standard Checklist',
              onAction: _applyStandardChecklist,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppButton(
              label: 'Add Custom Item',
              variant: AppButtonVariant.outlined,
              expand: true,
              onPressed: _addCustomItem,
            ),
          ),
        ],
      );
    }

    return Stack(
      children: <Widget>[
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          itemCount: widget.workspace.checklistResults.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (BuildContext context, int index) {
            return _ChecklistCard(
              result: widget.workspace.checklistResults[index],
              onUpdated: widget.onUpdated,
            );
          },
        ),
        Positioned(
          right: AppSpacing.md,
          bottom: AppSpacing.md,
          child: FloatingActionButton.extended(
            onPressed: _addCustomItem,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Item'),
          ),
        ),
      ],
    );
  }
}

class _ChecklistCard extends StatefulWidget {
  const _ChecklistCard({required this.result, required this.onUpdated});

  final ChecklistResultEntity result;
  final VoidCallback onUpdated;

  @override
  State<_ChecklistCard> createState() => _ChecklistCardState();
}

class _ChecklistCardState extends State<_ChecklistCard> {
  bool _isUpdating = false;

  ChecklistItemStatus _nextStatus(ChecklistItemStatus current) {
    return switch (current) {
      ChecklistItemStatus.notStarted => ChecklistItemStatus.passed,
      ChecklistItemStatus.passed => ChecklistItemStatus.failed,
      ChecklistItemStatus.failed => ChecklistItemStatus.notApplicable,
      ChecklistItemStatus.notApplicable => ChecklistItemStatus.notStarted,
    };
  }

  Future<void> _toggleStatus() async {
    setState(() => _isUpdating = true);
    final result = widget.result;
    final updated = ChecklistResultEntity(
      id: result.id,
      inspectionId: result.inspectionId,
      templateId: result.templateId,
      itemId: result.itemId,
      title: result.title,
      description: result.description,
      required: result.required,
      status: _nextStatus(result.status),
      notes: result.notes,
      completedAt: DateTime.now().toUtc(),
      sortOrder: result.sortOrder,
      sync: result.sync,
    );

    await sl<ChecklistRepository>().saveResult(updated);
    await sl<TimelineRepository>().add(
      TimelineEventEntity(
        id: const Uuid().v4(),
        inspectionId: result.inspectionId,
        eventType: updated.status == ChecklistItemStatus.failed
            ? TimelineEventType.checklistItemFailed
            : TimelineEventType.other,
        title: 'Checklist updated',
        description: '${result.title} marked as ${_statusLabel(updated.status)}.',
        createdAt: DateTime.now().toUtc(),
      ),
    );
    if (!mounted) return;
    setState(() => _isUpdating = false);
    widget.onUpdated();
  }

  static String _statusLabel(ChecklistItemStatus status) {
    return switch (status) {
      ChecklistItemStatus.notStarted => 'not started',
      ChecklistItemStatus.passed => 'passed',
      ChecklistItemStatus.failed => 'failed',
      ChecklistItemStatus.notApplicable => 'N/A',
    };
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return AppCard(
      elevated: true,
      onTap: _isUpdating ? null : _toggleStatus,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(result.title, style: context.textTheme.titleSmall),
              ),
              if (_isUpdating)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                _ChecklistStatusBadge(status: result.status),
            ],
          ),
          if (result.notes?.isNotEmpty == true) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(result.notes!, style: context.textTheme.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap to update status',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistStatusBadge extends StatelessWidget {
  const _ChecklistStatusBadge({required this.status});

  final ChecklistItemStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      ChecklistItemStatus.notStarted => 'Not started',
      ChecklistItemStatus.passed => 'Passed',
      ChecklistItemStatus.failed => 'Failed',
      ChecklistItemStatus.notApplicable => 'N/A',
    };

    return Text(label, style: context.textTheme.labelMedium);
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.workspace, required this.onEdit});

  final InspectionWorkspace workspace;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final notes = workspace.inspection.notes?.trim() ?? '';

    if (notes.isEmpty) {
      return EmptyState(
        title: 'No notes',
        message: 'Inspector notes for this inspection appear here.',
        icon: AppIcons.note,
        actionLabel: 'Add Notes',
        onAction: onEdit,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: <Widget>[
        AppCard(
          elevated: true,
          child: Text(notes, style: context.textTheme.bodyLarge),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Edit Notes',
          variant: AppButtonVariant.outlined,
          expand: true,
          onPressed: onEdit,
        ),
      ],
    );
  }
}

class _TimelineTab extends StatelessWidget {
  const _TimelineTab({required this.workspace});

  final InspectionWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    if (workspace.timeline.isEmpty) {
      return const EmptyState(
        title: 'No activity',
        message: 'Timeline events will appear as you work.',
        icon: Icons.timeline_rounded,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: workspace.timeline.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (BuildContext context, int index) {
        return _TimelineCard(event: workspace.timeline[index]);
      },
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.event});

  final TimelineEventEntity event;

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat.jm().format(event.createdAt.toLocal());

    return AppCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(event.title, style: context.textTheme.titleSmall),
              ),
              Text(timeLabel, style: context.textTheme.bodySmall),
            ],
          ),
          if (event.description.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.xxs),
            Text(event.description, style: context.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _ReportTab extends StatefulWidget {
  const _ReportTab({required this.workspace, required this.onGenerated});

  final InspectionWorkspace workspace;
  final VoidCallback onGenerated;

  @override
  State<_ReportTab> createState() => _ReportTabState();
}

class _ReportTabState extends State<_ReportTab> {
  bool _isGenerating = false;

  Future<void> _generateReport() async {
    final signaturePath = await context.push<String?>(AppRoutes.signature);

    setState(() => _isGenerating = true);

    final workspace = widget.workspace;
    final summary = await sl<IntelligenceService>().summarizeInspection(
      observationSummaries: workspace.observations
          .map((ObservationEntity o) => o.title)
          .toList(),
      checklistNotes: workspace.checklistResults
          .map((ChecklistResultEntity item) => '${item.title}: ${item.status.value}')
          .toList(),
      notes: workspace.inspection.notes ?? '',
    );

    final result = await sl<PdfReportService>().generateReport(
      inspectionId: workspace.inspection.id,
      signaturePath: signaturePath,
      executiveSummary: summary,
    );
    if (!mounted) return;

    setState(() => _isGenerating = false);
    result.fold(
      onSuccess: (String path) {
        widget.onGenerated();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Report saved to $path')));
      },
      onFailure: (failure) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );
  }

  Future<void> _previewReport(String path) async {
    final result = await sl<PdfReportService>().preview(path);
    if (!mounted) return;

    result.fold(
      onSuccess: (_) {},
      onFailure: (failure) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reports = widget.workspace.reports;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: <Widget>[
        AppButton(
          label: 'Generate PDF Report',
          icon: AppIcons.reports,
          expand: true,
          isLoading: _isGenerating,
          onPressed: _isGenerating ? null : _generateReport,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (reports.isEmpty)
          const EmptyState(
            title: 'No reports yet',
            message: 'Generate a PDF report from this inspection.',
            icon: AppIcons.reports,
          )
        else
          ...reports.map((ReportEntity report) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                elevated: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _reportStatusLabel(report.status),
                      style: context.textTheme.titleSmall,
                    ),
                    if (report.generatedAt != null)
                      Text(
                        DateFormat.yMMMd().format(
                          report.generatedAt!.toLocal(),
                        ),
                        style: context.textTheme.bodySmall,
                      ),
                    if (report.filePath != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: 'Preview',
                        variant: AppButtonVariant.outlined,
                        onPressed: () => _previewReport(report.filePath!),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  static String _reportStatusLabel(ReportStatus status) {
    return switch (status) {
      ReportStatus.draft => 'Draft report',
      ReportStatus.generating => 'Generating...',
      ReportStatus.ready => 'Ready report',
      ReportStatus.shared => 'Shared report',
    };
  }
}
