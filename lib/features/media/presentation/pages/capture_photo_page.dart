import 'dart:io';

import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/extensions/context_extensions.dart';
import 'package:field_lens/core/services/inspection_activity_service.dart';
import 'package:field_lens/core/services/ocr_service.dart';
import 'package:field_lens/core/widgets/app_button.dart';
import 'package:field_lens/core/widgets/app_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

/// Captures or picks a photo and attaches it to an inspection.
class CapturePhotoPage extends StatefulWidget {
  const CapturePhotoPage({required this.inspectionId, super.key});

  final String inspectionId;

  @override
  State<CapturePhotoPage> createState() => _CapturePhotoPageState();
}

class _CapturePhotoPageState extends State<CapturePhotoPage> {
  final _picker = ImagePicker();
  final ValueNotifier<String?> _imagePath = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _ocrText = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isBusy = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _imagePath.dispose();
    _ocrText.dispose();
    _isBusy.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    _isBusy.value = true;
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (!mounted) return;

    if (file == null) {
      _isBusy.value = false;
      return;
    }

    _imagePath.value = file.path;
    _ocrText.value = null;
    _isBusy.value = false;
  }

  Future<void> _runOcr() async {
    final path = _imagePath.value;
    if (path == null) return;
    _isBusy.value = true;
    final result = await sl<OcrService>().extractText(path);
    if (!mounted) return;

    _isBusy.value = false;
    result.fold(
      onSuccess: (text) => _ocrText.value = text,
      onFailure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  Future<void> _save() async {
    final path = _imagePath.value;
    if (path == null) return;
    _isBusy.value = true;

    final result = await sl<InspectionActivityService>().savePhoto(
      inspectionId: widget.inspectionId,
      sourcePath: path,
      ocrText: _ocrText.value,
    );
    if (!mounted) return;

    result.fold(
      onSuccess: (_) => context.pop(true),
      onFailure: (failure) {
        _isBusy.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Capture Photo',
      showBackButton: true,
      body: ValueListenableBuilder<String?>(
        valueListenable: _imagePath,
        builder: (BuildContext context, String? imagePath, _) {
          return ValueListenableBuilder<String?>(
            valueListenable: _ocrText,
            builder: (BuildContext context, String? ocrText, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: _isBusy,
                builder: (BuildContext context, bool isBusy, _) {
                  return ListView(
                    children: <Widget>[
                      if (imagePath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(imagePath),
                            height: 240,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          height: 200,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: context.colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.photo_camera_outlined,
                            size: 64,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: AppButton(
                              label: 'Camera',
                              icon: Icons.photo_camera_outlined,
                              variant: AppButtonVariant.secondary,
                              onPressed: isBusy
                                  ? null
                                  : () => _pick(ImageSource.camera),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppButton(
                              label: 'Gallery',
                              icon: Icons.photo_library_outlined,
                              variant: AppButtonVariant.secondary,
                              onPressed: isBusy
                                  ? null
                                  : () => _pick(ImageSource.gallery),
                            ),
                          ),
                        ],
                      ),
                      if (imagePath != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          label: 'Extract Text (OCR)',
                          icon: Icons.document_scanner_outlined,
                          variant: AppButtonVariant.secondary,
                          expand: true,
                          isLoading: isBusy,
                          onPressed: isBusy ? null : _runOcr,
                        ),
                        if (ocrText?.isNotEmpty == true) ...<Widget>[
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Detected text',
                            style: context.textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(ocrText!, style: context.textTheme.bodyMedium),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        AppButton(
                          label: 'Save Photo',
                          expand: true,
                          isLoading: isBusy,
                          onPressed: isBusy ? null : _save,
                        ),
                      ],
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
