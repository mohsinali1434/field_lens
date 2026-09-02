import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:field_lens/app/router/app_routes.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/extensions/context_extensions.dart';
import 'package:field_lens/core/widgets/app_card.dart';
import 'package:field_lens/core/widgets/app_button.dart';
import 'package:field_lens/core/widgets/app_scaffold.dart';
import 'package:field_lens/core/widgets/app_text_field.dart';
import 'package:field_lens/core/widgets/error_view.dart';
import 'package:field_lens/features/inspections/domain/usecases/create_inspection.dart';
import 'package:field_lens/features/inspections/presentation/bloc/create_inspection_bloc.dart';
import 'package:field_lens/features/inspections/presentation/bloc/create_inspection_event.dart';
import 'package:field_lens/features/inspections/presentation/bloc/create_inspection_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Simple form to create a new draft inspection.
class CreateInspectionPage extends StatefulWidget {
  const CreateInspectionPage({super.key});

  @override
  State<CreateInspectionPage> createState() => _CreateInspectionPageState();
}

class _CreateInspectionPageState extends State<CreateInspectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _clientController = TextEditingController();
  final _siteController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _clientController.dispose();
    _siteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final title = _titleController.text.trim();
    final client = _clientController.text.trim();
    final site = _siteController.text.trim();

    if (title.isEmpty || client.isEmpty || site.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title, client, and site are required.')),
      );
      return;
    }

    context.read<CreateInspectionBloc>().add(
      CreateInspectionSubmitted(
        CreateInspectionInput(
          title: _titleController.text,
          clientName: _clientController.text,
          siteName: _siteController.text,
          description: _descriptionController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateInspectionBloc>(
      create: (_) => sl<CreateInspectionBloc>(),
      child: BlocListener<CreateInspectionBloc, CreateInspectionState>(
        listener: (BuildContext context, CreateInspectionState state) {
          if (state is CreateInspectionSuccess) {
            context.go(AppRoutes.inspectionDetailPath(state.inspectionId));
          }
        },
        child: AppScaffold(
          title: 'New Inspection',
          showBackButton: true,
          body: BlocBuilder<CreateInspectionBloc, CreateInspectionState>(
            builder: (BuildContext context, CreateInspectionState state) {
              if (state is CreateInspectionFailure) {
                return ErrorView(
                  message: state.message,
                  onRetry: () => _submit(context),
                );
              }

              final isSubmitting = state is CreateInspectionSubmitting;

              return Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    AppCard(
                      elevated: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Inspection Information',
                            style: context.textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _titleController,
                            label: 'Title',
                            hint: 'e.g. Monthly site walkthrough',
                            enabled: !isSubmitting,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: _clientController,
                            label: 'Client',
                            hint: 'Client or company name',
                            enabled: !isSubmitting,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: _siteController,
                            label: 'Site',
                            hint: 'Property or site name',
                            enabled: !isSubmitting,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: _descriptionController,
                            label: 'Description',
                            hint: 'Brief description of this inspection',
                            maxLines: 4,
                            enabled: !isSubmitting,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: 'Create Inspection',
                      expand: true,
                      isLoading: isSubmitting,
                      onPressed: isSubmitting ? null : () => _submit(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
