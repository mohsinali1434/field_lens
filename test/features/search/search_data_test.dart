import 'package:drift/native.dart';
import 'package:field_lens/core/database/app_database.dart';
import 'package:field_lens/features/inspections/data/repositories/inspection_repository_impl.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:field_lens/features/observations/data/repositories/observation_repository_impl.dart';
import 'package:field_lens/features/observations/domain/entities/observation_entity.dart';
import 'package:field_lens/features/observations/domain/entities/observation_enums.dart';
import 'package:field_lens/features/search/domain/usecases/search_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late SearchData searchData;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    searchData = SearchData(
      inspectionRepository: InspectionRepositoryImpl(database),
      observationRepository: ObservationRepositoryImpl(database),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('returns empty results for blank query', () async {
    final result = await searchData('   ');
    expect(result.valueOrNull?.isEmpty, isTrue);
  });

  test('finds inspections by title', () async {
    final now = DateTime.utc(2026, 1, 1);
    await InspectionRepositoryImpl(database).saveInspection(
      InspectionEntity(
        id: 'insp-search',
        title: 'Warehouse Safety Audit',
        clientName: 'Acme',
        siteName: 'Warehouse',
        description: 'Monthly audit',
        status: InspectionStatus.inProgress,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final result = await searchData('warehouse');
    expect(result.valueOrNull?.inspections, hasLength(1));
    expect(result.valueOrNull?.observations, isEmpty);
  });

  test('finds observations by description', () async {
    final now = DateTime.utc(2026, 1, 1);
    await InspectionRepositoryImpl(database).saveInspection(
      InspectionEntity(
        id: 'insp-obs-search',
        title: 'Site Walk',
        clientName: 'Acme',
        siteName: 'Site',
        description: 'Walkthrough',
        status: InspectionStatus.inProgress,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await ObservationRepositoryImpl(database).saveObservation(
      ObservationEntity(
        id: 'obs-search',
        inspectionId: 'insp-obs-search',
        title: 'Leak',
        description: 'Visible mold growth in corner',
        category: ObservationCategory.cleanliness,
        severity: ObservationSeverity.medium,
        status: ObservationStatus.open,
        createdAt: now,
        updatedAt: now,
      ),
    );

    final result = await searchData('mold');
    expect(result.valueOrNull?.inspections, isEmpty);
    expect(result.valueOrNull?.observations, hasLength(1));
  });
}
