import 'dart:io';
import 'dart:typed_data';

import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/extensions/context_extensions.dart';
import 'package:field_lens/core/widgets/app_button.dart';
import 'package:field_lens/core/widgets/app_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

/// Captures an inspector signature for PDF reports.
class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key});

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  final _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final ValueNotifier<bool> _isSaving = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _controller.dispose();
    _isSaving.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign before saving.')),
      );
      return;
    }

    _isSaving.value = true;
    try {
      final Uint8List? bytes = await _controller.toPngBytes();
      if (bytes == null) {
        throw StateError('Failed to export signature');
      }
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      Navigator.of(context).pop(file.path);
    } on Object catch (error) {
      if (!mounted) return;
      _isSaving.value = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save signature: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Sign Report',
      showBackButton: true,
      body: ValueListenableBuilder<bool>(
        valueListenable: _isSaving,
        builder: (BuildContext context, bool isSaving, _) {
          return Column(
            children: <Widget>[
              Text(
                'Draw your signature below',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: context.colors.outline),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Signature(
                    controller: _controller,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isSaving ? null : _controller.clear,
                  child: const Text('Clear signature'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AppButton(
                      label: 'Skip',
                      variant: AppButtonVariant.outlined,
                      onPressed: isSaving ? null : () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      label: 'Save',
                      isLoading: isSaving,
                      onPressed: isSaving ? null : _save,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
