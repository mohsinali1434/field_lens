import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/services/inspection_activity_service.dart';
import 'package:field_lens/core/widgets/app_button.dart';
import 'package:field_lens/core/widgets/app_scaffold.dart';
import 'package:field_lens/core/widgets/app_text_field.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/repositories/inspection_repository.dart';
import 'package:material_ui/material_ui.dart';

/// Quick note editor for an inspection.
class NoteFormPage extends StatefulWidget {
  const NoteFormPage({required this.inspectionId, super.key});

  final String inspectionId;

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final _controller = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  InspectionEntity? _inspection;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await sl<InspectionRepository>().getInspectionById(
      widget.inspectionId,
    );
    if (!mounted) return;

    result.fold(
      onSuccess: (inspection) {
        setState(() {
          _inspection = inspection;
          _controller.text = inspection.notes ?? '';
          _isLoading = false;
        });
      },
      onFailure: (failure) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  Future<void> _save() async {
    final inspection = _inspection;
    if (inspection == null) return;

    setState(() => _isSaving = true);
    final result = await sl<InspectionActivityService>().saveNote(
      inspection: inspection,
      note: _controller.text.trim(),
    );
    if (!mounted) return;

    result.fold(
      onSuccess: (_) => Navigator.of(context).pop(true),
      onFailure: (failure) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Inspection Notes',
      showBackButton: true,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                AppTextField(
                  controller: _controller,
                  label: 'Notes',
                  hint: 'Add site notes, follow-ups, or reminders',
                  maxLines: 8,
                  enabled: !_isSaving,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Save Notes',
                  expand: true,
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _save,
                ),
              ],
            ),
    );
  }
}
