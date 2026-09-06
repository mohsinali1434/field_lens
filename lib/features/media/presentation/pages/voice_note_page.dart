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

class _VoiceNoteUiState {
  const _VoiceNoteUiState({
    this.isRecording = false,
    this.isBusy = false,
    this.recordingPath,
    this.elapsed = Duration.zero,
  });

  final bool isRecording;
  final bool isBusy;
  final String? recordingPath;
  final Duration elapsed;

  _VoiceNoteUiState copyWith({
    bool? isRecording,
    bool? isBusy,
    String? recordingPath,
    Duration? elapsed,
    bool clearPath = false,
  }) {
    return _VoiceNoteUiState(
      isRecording: isRecording ?? this.isRecording,
      isBusy: isBusy ?? this.isBusy,
      recordingPath: clearPath ? null : (recordingPath ?? this.recordingPath),
      elapsed: elapsed ?? this.elapsed,
    );
  }
}

class _VoiceNotePageState extends State<VoiceNotePage> {
  final ValueNotifier<_VoiceNoteUiState> _state =
      ValueNotifier<_VoiceNoteUiState>(const _VoiceNoteUiState());
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _state.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    _state.value = _state.value.copyWith(isBusy: true);
    final result = await sl<AudioRecorderService>().start();
    if (!mounted) return;

    result.fold(
      onSuccess: (_) {
        _state.value = _state.value.copyWith(
          isRecording: true,
          isBusy: false,
          elapsed: Duration.zero,
          clearPath: true,
        );
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          final current = _state.value;
          _state.value = current.copyWith(
            elapsed: current.elapsed + const Duration(seconds: 1),
          );
        });
      },
      onFailure: (failure) {
        _state.value = _state.value.copyWith(isBusy: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _state.value = _state.value.copyWith(isBusy: true);
    final result = await sl<AudioRecorderService>().stop();
    if (!mounted) return;

    result.fold(
      onSuccess: (path) {
        _state.value = _state.value.copyWith(
          isRecording: false,
          isBusy: false,
          recordingPath: path,
        );
      },
      onFailure: (failure) {
        _state.value = _state.value.copyWith(
          isRecording: false,
          isBusy: false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  Future<void> _playPreview() async {
    final path = _state.value.recordingPath;
    if (path == null) return;
    await sl<AudioPlayerService>().play(path);
  }

  Future<void> _save() async {
    final path = _state.value.recordingPath;
    if (path == null) return;
    _state.value = _state.value.copyWith(isBusy: true);

    final result = await sl<InspectionActivityService>().saveAudio(
      inspectionId: widget.inspectionId,
      sourcePath: path,
    );
    if (!mounted) return;

    result.fold(
      onSuccess: (_) => Navigator.of(context).pop(true),
      onFailure: (failure) {
        _state.value = _state.value.copyWith(isBusy: false);
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
      body: ValueListenableBuilder<_VoiceNoteUiState>(
        valueListenable: _state,
        builder: (BuildContext context, _VoiceNoteUiState state, _) {
          return Column(
            children: <Widget>[
              const Spacer(),
              Icon(
                state.isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
                size: 96,
                color: state.isRecording
                    ? context.colors.error
                    : context.colors.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                state.isRecording ? 'Recording…' : 'Tap record to start',
                style: context.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _formatDuration(state.elapsed),
                style: context.textTheme.headlineSmall,
              ),
              const Spacer(),
              if (state.recordingPath != null)
                AppButton(
                  label: 'Preview',
                  icon: Icons.play_arrow_rounded,
                  variant: AppButtonVariant.secondary,
                  expand: true,
                  onPressed: state.isBusy ? null : _playPreview,
                ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: state.isRecording ? 'Stop' : 'Record',
                icon: state.isRecording
                    ? Icons.stop_rounded
                    : Icons.fiber_manual_record,
                expand: true,
                isLoading: state.isBusy,
                onPressed: state.isBusy
                    ? null
                    : state.isRecording
                        ? _stopRecording
                        : _startRecording,
              ),
              if (state.recordingPath != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Save Voice Note',
                  expand: true,
                  isLoading: state.isBusy,
                  onPressed: state.isBusy ? null : _save,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],
          );
        },
      ),
    );
  }
}
