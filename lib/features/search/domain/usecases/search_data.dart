import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/repositories/inspection_repository.dart';
import 'package:field_lens/features/observations/domain/entities/observation_entity.dart';
import 'package:field_lens/features/observations/domain/repositories/observation_repository.dart';

/// Grouped local search results.
class SearchResults {
  const SearchResults({
    required this.inspections,
    required this.observations,
  });

  final List<InspectionEntity> inspections;
  final List<ObservationEntity> observations;

  bool get isEmpty => inspections.isEmpty && observations.isEmpty;
}

/// Searches inspections and observations stored on device.
class SearchData {
  const SearchData({
    required InspectionRepository inspectionRepository,
    required ObservationRepository observationRepository,
  }) : _inspectionRepository = inspectionRepository,
       _observationRepository = observationRepository;

  final InspectionRepository _inspectionRepository;
  final ObservationRepository _observationRepository;

  Future<Result<SearchResults>> call(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const Success<SearchResults>(
        SearchResults(
          inspections: <InspectionEntity>[],
          observations: <ObservationEntity>[],
        ),
      );
    }

    final inspectionsResult = await _inspectionRepository.getInspections();
    if (inspectionsResult.isFailure) {
      return Error<SearchResults>(inspectionsResult.failureOrNull!);
    }

    final needle = trimmed.toLowerCase();
    final inspections = inspectionsResult.valueOrNull!
        .where((InspectionEntity inspection) => _matchesInspection(inspection, needle))
        .toList();

    final observations = <ObservationEntity>[];
    for (final inspection in inspectionsResult.valueOrNull!) {
      final observationResult = await _observationRepository.getByInspectionId(
        inspection.id,
      );
      final rows = observationResult.valueOrNull ?? <ObservationEntity>[];
      observations.addAll(
        rows.where(
          (ObservationEntity observation) =>
              _matchesObservation(observation, needle),
        ),
      );
    }

    return Success<SearchResults>(
      SearchResults(inspections: inspections, observations: observations),
    );
  }

  bool _matchesInspection(InspectionEntity inspection, String needle) {
    return inspection.title.toLowerCase().contains(needle) ||
        inspection.clientName.toLowerCase().contains(needle) ||
        inspection.siteName.toLowerCase().contains(needle) ||
        inspection.description.toLowerCase().contains(needle) ||
        (inspection.address?.toLowerCase().contains(needle) ?? false);
  }

  bool _matchesObservation(ObservationEntity observation, String needle) {
    return observation.title.toLowerCase().contains(needle) ||
        observation.description.toLowerCase().contains(needle) ||
        observation.category.value.toLowerCase().contains(needle);
  }
}
