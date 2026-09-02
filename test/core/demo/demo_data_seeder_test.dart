import 'package:drift/native.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/demo/demo_data_seeder.dart';
import 'package:field_lens/features/checklists/data/repositories/checklist_repository_impl.dart';
import 'package:field_lens/features/inspections/data/repositories/inspection_repository_impl.dart';
import 'package:field_lens/features/observations/data/repositories/observation_repository_impl.dart';
import 'package:field_lens/features/reports/data/repositories/report_repository_impl.dart';
import 'package:field_lens/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DemoDataSeeder seeder;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    seeder = DemoDataSeeder(
      inspectionRepository: InspectionRepositoryImpl(database),
      observationRepository: ObservationRepositoryImpl(database),
      checklistRepository: ChecklistRepositoryImpl(database),
      reportRepository: ReportRepositoryImpl(database),
      settingsRepository: SettingsRepositoryImpl(database),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('seeds demo data on first run', () async {
    final result = await seeder.seedIfNeeded();
    expect(result.isSuccess, isTrue);

    final inspections =
        await InspectionRepositoryImpl(database).getInspections();
    expect(inspections.valueOrNull, hasLength(1));
    expect(
      inspections.valueOrNull!.first.title,
      'Residential Property Inspection',
    );

    final observations = await ObservationRepositoryImpl(database)
        .getByInspectionId(inspections.valueOrNull!.first.id);
    expect(observations.valueOrNull, hasLength(3));
  });

  test('does not seed twice', () async {
    await seeder.seedIfNeeded();
    await seeder.seedIfNeeded();

    final inspections =
        await InspectionRepositoryImpl(database).getInspections();
    expect(inspections.valueOrNull, hasLength(1));
  });
}
