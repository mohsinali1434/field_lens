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

class _ObservationFormPageState extends State<ObservationFormPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  ObservationCategory _category = ObservationCategory.other;
  ObservationSeverity _severity = ObservationSeverity.low;
  ObservationStatus _status = ObservationStatus.open;

  bool _isSaving = false;
  bool _isAnalyzing = false;
  bool _isLoading = false;
  DateTime? _createdAt;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      unawaited(_loadObservation());
    }
  }

  Future<void> _loadObservation() async {
    setState(() => _isLoading = true);
    final result = await sl<ObservationRepository>().getById(
      widget.observationId!,
    );
    if (!mounted) return;

    result.fold(
      onSuccess: (ObservationEntity observation) {
        _titleController.text = observation.title;
        _descriptionController.text = observation.description;
        _category = observation.category;
        _severity = observation.severity;
        _status = observation.status;
        _createdAt = observation.createdAt;
        setState(() => _isLoading = false);
      },
      onFailure: (failure) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
        context.pop();
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _applySuggestions() async {
    final text = '${_titleController.text} ${_descriptionController.text}'.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a title or description first.')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);
    final suggestion = await sl<IntelligenceService>().analyzeObservation(
      text: text,
    );
    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
      if (_titleController.text.trim().isEmpty) {
        _titleController.text = suggestion.title;
      }
      _category = suggestion.category;
      _severity = suggestion.severity;
      _status = suggestion.status;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Suggestions applied.')),
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final now = DateTime.now().toUtc();
    final isNew = !widget.isEditing;
    final observation = ObservationEntity(
      id: widget.observationId ?? const Uuid().v4(),
      inspectionId: widget.inspectionId,
      title: title,
      description: description,
      category: _category,
      severity: _severity,
      status: _status,
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
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
            enabled: !_isSaving,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Describe what you observed',
            maxLines: 4,
            enabled: !_isSaving,
          ),
          const SizedBox(height: AppSpacing.md),
          _LabeledField(
            label: 'Category',
            child: DropdownButtonFormField<ObservationCategory>(
              value: _category,
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
              onChanged: _isSaving
                  ? null
                  : (ObservationCategory? value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _LabeledField(
            label: 'Severity',
            child: DropdownButtonFormField<ObservationSeverity>(
              value: _severity,
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
              onChanged: _isSaving
                  ? null
                  : (ObservationSeverity? value) {
                      if (value != null) {
                        setState(() => _severity = value);
                      }
                    },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _LabeledField(
            label: 'Status',
            child: DropdownButtonFormField<ObservationStatus>(
              value: _status,
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
              onChanged: _isSaving
                  ? null
                  : (ObservationStatus? value) {
                      if (value != null) {
                        setState(() => _status = value);
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
            isLoading: _isAnalyzing,
            onPressed: _isSaving || _isAnalyzing ? null : _applySuggestions,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: widget.isEditing ? 'Save Changes' : 'Save Observation',
            expand: true,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
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
