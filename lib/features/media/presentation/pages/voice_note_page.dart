import 'dart:async';

import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/extensions/context_extensions.dart';
import 'package:field_lens/core/services/audio_player_service.dart';
import 'package:field_lens/core/services/audio_recorder_service.dart';
import 'package:field_lens/core/services/inspection_activity_service.dart';
import 'package:field_lens/core/widgets/app_button.dart';
import 'package:field_lens/core/widgets/app_scaffold.dart';
import 'package:material_ui/material_ui.dart';

/// Records a voice note and attaches it to an inspection.
class VoiceNotePage extends StatefulWidget {
  const VoiceNotePage({required this.inspectionId, super.key});

  final String inspectionId;

  @override
  State<VoiceNotePage> createState() => _VoiceNotePageState();
}

class _VoiceNotePageState extends State<VoiceNotePage> {
  bool _isRecording = false;
  bool _isBusy = false;
  String? _recordingPath;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    setState(() => _isBusy = true);
    final result = await sl<AudioRecorderService>().start();
    if (!mounted) return;

    result.fold(
      onSuccess: (_) {
        setState(() {
          _isRecording = true;
          _isBusy = false;
          _elapsed = Duration.zero;
          _recordingPath = null;
        });
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) {
            setState(() => _elapsed += const Duration(seconds: 1));
          }
        });
      },
      onFailure: (failure) {
        setState(() => _isBusy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    setState(() => _isBusy = true);
    final result = await sl<AudioRecorderService>().stop();
    if (!mounted) return;

    result.fold(
      onSuccess: (path) {
        setState(() {
          _isRecording = false;
          _isBusy = false;
          _recordingPath = path;
        });
      },
      onFailure: (failure) {
        setState(() {
          _isRecording = false;
          _isBusy = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  Future<void> _playPreview() async {
    if (_recordingPath == null) return;
    await sl<AudioPlayerService>().play(_recordingPath!);
  }

  Future<void> _save() async {
    if (_recordingPath == null) return;
    setState(() => _isBusy = true);

    final result = await sl<InspectionActivityService>().saveAudio(
      inspectionId: widget.inspectionId,
      sourcePath: _recordingPath!,
    );
    if (!mounted) return;

    result.fold(
      onSuccess: (_) => Navigator.of(context).pop(true),
      onFailure: (failure) {
        setState(() => _isBusy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Voice Note',
      showBackButton: true,
      body: Column(
        children: <Widget>[
          const Spacer(),
          Icon(
            _isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
            size: 96,
            color: _isRecording
                ? context.colors.error
                : context.colors.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _isRecording ? 'Recording…' : 'Tap record to start',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _formatDuration(_elapsed),
            style: context.textTheme.headlineSmall,
          ),
          const Spacer(),
          if (_recordingPath != null)
            AppButton(
              label: 'Preview',
              icon: Icons.play_arrow_rounded,
              variant: AppButtonVariant.secondary,
              expand: true,
              onPressed: _isBusy ? null : _playPreview,
            ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: _isRecording ? 'Stop' : 'Record',
            icon: _isRecording ? Icons.stop_rounded : Icons.fiber_manual_record,
            expand: true,
            isLoading: _isBusy,
            onPressed: _isBusy
                ? null
                : _isRecording
                ? _stopRecording
                : _startRecording,
          ),
          if (_recordingPath != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Save Voice Note',
              expand: true,
              isLoading: _isBusy,
              onPressed: _isBusy ? null : _save,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
