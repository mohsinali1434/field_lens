import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/inspections/domain/repositories/inspection_repository.dart';
import 'package:field_lens/features/observations/domain/repositories/observation_repository.dart';
import 'package:field_lens/features/settings/domain/repositories/settings_repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Exports local app data as a ZIP archive.
class BackupService {
  BackupService({
    required InspectionRepository inspectionRepository,
    required ObservationRepository observationRepository,
    required SettingsRepository settingsRepository,
  }) : _inspectionRepository = inspectionRepository,
       _observationRepository = observationRepository,
       _settingsRepository = settingsRepository;

  final InspectionRepository _inspectionRepository;
  final ObservationRepository _observationRepository;
  final SettingsRepository _settingsRepository;

  Future<Result<String>> exportBackup() async {
    try {
      final inspections =
          (await _inspectionRepository.getInspections()).valueOrNull ?? [];
      final metadata = <String, dynamic>{
        'version': 1,
        'exportedAt': DateTime.now().toUtc().toIso8601String(),
        'inspections': inspections
            .map(
              (inspection) => <String, dynamic>{
                'id': inspection.id,
                'title': inspection.title,
                'clientName': inspection.clientName,
                'siteName': inspection.siteName,
                'status': inspection.status.value,
              },
            )
            .toList(),
      };

      for (final inspection in inspections) {
        final observations =
            (await _observationRepository.getByInspectionId(inspection.id))
                .valueOrNull ??
            [];
        metadata['observations_${inspection.id}'] = observations
            .map(
              (obs) => <String, dynamic>{
                'id': obs.id,
                'title': obs.title,
                'description': obs.description,
              },
            )
            .toList();
      }

      final settings =
          (await _settingsRepository.getAllSettings()).valueOrNull ?? [];
      metadata['settings'] = settings
          .map((s) => <String, dynamic>{'key': s.key, 'value': s.value})
          .toList();

      final archive = Archive();
      final jsonBytes = utf8.encode(jsonEncode(metadata));
      archive.addFile(
        ArchiveFile('metadata.json', jsonBytes.length, jsonBytes),
      );

      final zipBytes = ZipEncoder().encode(archive)!;

      final docs = await getApplicationDocumentsDirectory();
      final exportDir = Directory(p.join(docs.path, 'exports'));
      if (!exportDir.existsSync()) {
        await exportDir.create(recursive: true);
      }
      final filePath = p.join(
        exportDir.path,
        'fieldlens_backup_${DateTime.now().millisecondsSinceEpoch}.zip',
      );
      await File(filePath).writeAsBytes(zipBytes);
      return Success<String>(filePath);
    } on Object catch (error) {
      return Error<String>(StorageFailure(message: 'Export failed: $error'));
    }
  }

  Future<Result<void>> shareBackup(String filePath) async {
    try {
      await Share.shareXFiles(<XFile>[
        XFile(filePath),
      ], text: 'FieldLens backup');
      return const Success<void>(null);
    } on Object catch (error) {
      return Error<void>(StorageFailure(message: 'Share failed: $error'));
    }
  }
}
