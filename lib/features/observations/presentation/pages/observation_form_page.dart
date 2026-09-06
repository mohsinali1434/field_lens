import 'dart:async';

import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/extensions/context_extensions.dart';
import 'package:field_lens/core/services/intelligence_service.dart';
import 'package:field_lens/core/widgets/app_button.dart';
import 'package:field_lens/core/widgets/app_scaffold.dart';
import 'package:field_lens/core/widgets/app_text_field.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_type.dart';
import 'package:field_lens/features/inspections/domain/repositories/timeline_repository.dart';
import 'package:field_lens/features/observations/domain/entities/observation_entity.dart';
import 'package:field_lens/features/observations/domain/entities/observation_enums.dart';
import 'package:field_lens/features/observations/domain/repositories/observation_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

/// Form to create or edit an observation for an inspection.
class ObservationFormPage extends StatefulWidget {
  const ObservationFormPage({
    required this.inspectionId,
    this.observationId,
    super.key,
  });

  final String inspectionId;
  final String? observationId;

  bool get isEditing => observationId != null;

  @override
  State<ObservationFormPage> createState() => _ObservationFormPageState();
}

class _ObservationFormUiState {
  const _ObservationFormUiState({
    this.category = ObservationCategory.other,
    this.severity = ObservationSeverity.low,
    this.status = ObservationStatus.open,
    this.isSaving = false,
    this.isAnalyzing = false,
    this.isLoading = false,
  });

  final ObservationCategory category;
  final ObservationSeverity severity;
  final ObservationStatus status;
  final bool isSaving;
  final bool isAnalyzing;
  final bool isLoading;

  _ObservationFormUiState copyWith({
    ObservationCategory? category,
    ObservationSeverity? severity,
    ObservationStatus? status,
    bool? isSaving,
    bool? isAnalyzing,
    bool? isLoading,
  }) {
    return _ObservationFormUiState(
      category: category ?? this.category,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      isSaving: isSaving ?? this.isSaving,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class _ObservationFormPageState extends State<ObservationFormPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ValueNotifier<_ObservationFormUiState> _state =
      ValueNotifier<_ObservationFormUiState>(const _ObservationFormUiState());
  DateTime? _createdAt;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      unawaited(_loadObservation());
    }
  }

  Future<void> _loadObservation() async {
    _state.value = _state.value.copyWith(isLoading: true);
    final result = await sl<ObservationRepository>().getById(
      widget.observationId!,
    );
    if (!mounted) return;

    result.fold(
      onSuccess: (ObservationEntity observation) {
        _titleController.text = observation.title;
        _descriptionController.text = observation.description;
        _createdAt = observation.createdAt;
        _state.value = _state.value.copyWith(
          category: observation.category,
          severity: observation.severity,
          status: observation.status,
          isLoading: false,
        );
      },
      onFailure: (failure) {
        _state.value = _state.value.copyWith(isLoading: false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
        context.pop();
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _state.dispose();
    super.dispose();
  }

  Future<void> _applySuggestions() async {
    final text = '${_titleController.text} ${_descriptionController.text}'
        .trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title or description first.')),
      );
      return;
    }

    _state.value = _state.value.copyWith(isAnalyzing: true);
    final suggestion = await sl<IntelligenceService>().analyzeObservation(
      text: text,
    );
    if (!mounted) return;

    if (_titleController.text.trim().isEmpty) {
      _titleController.text = suggestion.title;
    }
    _state.value = _state.value.copyWith(
      isAnalyzing: false,
      category: suggestion.category,
      severity: suggestion.severity,
      status: suggestion.status,
    );

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Suggestions applied.')));
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Title is required.')));
      return;
    }

    final ui = _state.value;
    _state.value = ui.copyWith(isSaving: true);
    final now = DateTime.now().toUtc();
    final isNew = !widget.isEditing;
    final observation = ObservationEntity(
      id: widget.observationId ?? const Uuid().v4(),
      inspectionId: widget.inspectionId,
      title: title,
      description: description,
      category: ui.category,
      severity: ui.severity,
      status: ui.status,
      createdAt: _createdAt ?? now,
      updatedAt: now,
    );

    final result = await sl<ObservationRepository>().saveObservation(
      observation,
    );
    if (!mounted) return;

    await result.fold(
      onSuccess: (_) async {
        if (isNew) {
          await sl<TimelineRepository>().add(
            TimelineEventEntity(
              id: const Uuid().v4(),
              inspectionId: widget.inspectionId,
              eventType: TimelineEventType.observationCreated,
              title: 'Observation added',
              description: 'Added observation "$title".',
              createdAt: now,
            ),
          );
        }
        if (mounted) context.pop(true);
      },
      onFailure: (failure) async {
        _state.value = _state.value.copyWith(isSaving: false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_ObservationFormUiState>(
      valueListenable: _state,
      builder: (BuildContext context, _ObservationFormUiState state, _) {
        if (state.isLoading) {
          return const AppScaffold(
            title: 'Observation',
            showBackButton: true,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return AppScaffold(
          title: widget.isEditing ? 'Edit Observation' : 'New Observation',
          showBackButton: true,
          body: ListView(
            children: <Widget>[
              Text('Observation Details', style: context.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Brief summary of the issue',
                enabled: !state.isSaving,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe what you observed',
                maxLines: 4,
                enabled: !state.isSaving,
              ),
              const SizedBox(height: AppSpacing.md),
              _LabeledField(
                label: 'Category',
                child: DropdownButtonFormField<ObservationCategory>(
                  key: ValueKey<ObservationCategory>(state.category),
                  initialValue: state.category,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: ObservationCategory.values
                      .map(
                        (ObservationCategory category) => DropdownMenuItem(
                          value: category,
                          child: Text(_labelCategory(category)),
                        ),
                      )
                      .toList(),
                  onChanged: state.isSaving
                      ? null
                      : (ObservationCategory? value) {
                          if (value != null) {
                            _state.value = _state.value.copyWith(
                              category: value,
                            );
                          }
                        },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _LabeledField(
                label: 'Severity',
                child: DropdownButtonFormField<ObservationSeverity>(
                  key: ValueKey<ObservationSeverity>(state.severity),
                  initialValue: state.severity,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: ObservationSeverity.values
                      .map(
                        (ObservationSeverity severity) => DropdownMenuItem(
                          value: severity,
                          child: Text(_labelSeverity(severity)),
                        ),
                      )
                      .toList(),
                  onChanged: state.isSaving
                      ? null
                      : (ObservationSeverity? value) {
                          if (value != null) {
                            _state.value = _state.value.copyWith(
                              severity: value,
                            );
                          }
                        },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _LabeledField(
                label: 'Status',
                child: DropdownButtonFormField<ObservationStatus>(
                  key: ValueKey<ObservationStatus>(state.status),
                  initialValue: state.status,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: ObservationStatus.values
                      .map(
                        (ObservationStatus status) => DropdownMenuItem(
                          value: status,
                          child: Text(_labelStatus(status)),
                        ),
                      )
                      .toList(),
                  onChanged: state.isSaving
                      ? null
                      : (ObservationStatus? value) {
                          if (value != null) {
                            _state.value = _state.value.copyWith(status: value);
                          }
                        },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Get Suggestions',
                variant: AppButtonVariant.secondary,
                icon: Icons.auto_awesome_rounded,
                expand: true,
                isLoading: state.isAnalyzing,
                onPressed: state.isSaving || state.isAnalyzing
                    ? null
                    : _applySuggestions,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: widget.isEditing ? 'Save Changes' : 'Save Observation',
                expand: true,
                isLoading: state.isSaving,
                onPressed: state.isSaving ? null : _save,
              ),
            ],
          ),
        );
      },
    );
  }

  static String _labelCategory(ObservationCategory category) {
    return switch (category) {
      ObservationCategory.structural => 'Structural',
      ObservationCategory.electrical => 'Electrical',
      ObservationCategory.plumbing => 'Plumbing',
      ObservationCategory.safety => 'Safety',
      ObservationCategory.maintenance => 'Maintenance',
      ObservationCategory.cleanliness => 'Cleanliness',
      ObservationCategory.equipment => 'Equipment',
      ObservationCategory.other => 'Other',
    };
  }

  static String _labelSeverity(ObservationSeverity severity) {
    return switch (severity) {
      ObservationSeverity.low => 'Low',
      ObservationSeverity.medium => 'Medium',
      ObservationSeverity.high => 'High',
      ObservationSeverity.critical => 'Critical',
    };
  }

  static String _labelStatus(ObservationStatus status) {
    return switch (status) {
      ObservationStatus.open => 'Open',
      ObservationStatus.inProgress => 'In Progress',
      ObservationStatus.resolved => 'Resolved',
      ObservationStatus.ignored => 'Ignored',
    };
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(label, style: context.textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }
}
