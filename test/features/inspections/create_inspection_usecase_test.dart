import 'package:drift/native.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/core/services/checklist_setup_service.dart';
import 'package:field_lens/features/checklists/data/repositories/checklist_repository_impl.dart';
import 'package:field_lens/features/inspections/data/repositories/inspection_repository_impl.dart';
import 'package:field_lens/features/inspections/data/repositories/timeline_repository_impl.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:field_lens/features/inspections/domain/usecases/create_inspection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late CreateInspectionUseCase useCase;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    useCase = CreateInspectionUseCase(
      repository: InspectionRepositoryImpl(database),
      checklistSetupService: ChecklistSetupService(
        checklistRepository: ChecklistRepositoryImpl(database),
      ),
      timelineRepository: TimelineRepositoryImpl(database),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('creates draft inspection with trimmed fields', () async {
    final result = await useCase(
      const CreateInspectionInput(
        title: '  New Site  ',
        clientName: '  Acme Corp ',
        siteName: ' Warehouse ',
        description: ' Initial walkthrough ',
      ),
    );

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.title, 'New Site');
    expect(result.valueOrNull?.clientName, 'Acme Corp');
    expect(result.valueOrNull?.siteName, 'Warehouse');
    expect(result.valueOrNull?.description, 'Initial walkthrough');
    expect(result.valueOrNull?.status, InspectionStatus.draft);
    expect(result.valueOrNull?.id, isNotEmpty);
  });
}
