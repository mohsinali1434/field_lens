import 'package:field_lens/core/services/intelligence_service.dart';
import 'package:field_lens/features/observations/domain/entities/observation_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late RuleBasedIntelligenceService service;

  setUp(() {
    service = RuleBasedIntelligenceService();
  });

  test('classifies structural crack observations', () async {
    final suggestion = await service.analyzeObservation(
      text: 'Large crack in the structural wall near the entrance',
    );

    expect(suggestion.category, ObservationCategory.structural);
    expect(suggestion.severity, ObservationSeverity.high);
    expect(suggestion.title, contains('Crack'));
  });

  test('classifies electrical issues', () async {
    final suggestion = await service.analyzeObservation(
      text: 'Exposed wiring near the electrical panel',
    );

    expect(suggestion.category, ObservationCategory.electrical);
    expect(suggestion.severity, ObservationSeverity.critical);
  });

  test('classifies plumbing leaks', () async {
    final suggestion = await service.analyzeObservation(
      text: 'Minor water leak under the kitchen sink',
    );

    expect(suggestion.category, ObservationCategory.plumbing);
    expect(suggestion.severity, ObservationSeverity.medium);
  });

  test('summarizes inspection with observations', () async {
    final summary = await service.summarizeInspection(
      observationSummaries: <String>['Water leak in basement'],
      checklistNotes: <String>['Drain cover missing'],
      notes: 'Follow up next week',
    );

    expect(summary, contains('1 observation'));
    expect(summary, contains('Water leak'));
    expect(summary, contains('Follow up next week'));
  });

  test('summarizes empty inspection', () async {
    final summary = await service.summarizeInspection(
      observationSummaries: <String>[],
      checklistNotes: <String>[],
      notes: '',
    );

    expect(summary, contains('No observations recorded'));
  });
}
