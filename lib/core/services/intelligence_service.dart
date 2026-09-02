import 'package:field_lens/features/observations/domain/entities/observation_enums.dart';

/// Suggested observation fields from captured text.
class ObservationSuggestion {
  const ObservationSuggestion({
    required this.title,
    required this.category,
    required this.severity,
    required this.status,
  });

  final String title;
  final ObservationCategory category;
  final ObservationSeverity severity;
  final ObservationStatus status;
}

/// Optional intelligence layer for classification and summaries.
abstract class IntelligenceService {
  Future<ObservationSuggestion> analyzeObservation({
    required String text,
    String? ocrText,
    String? transcription,
  });

  Future<String> summarizeInspection({
    required List<String> observationSummaries,
    required List<String> checklistNotes,
    required String notes,
  });
}

/// Rule-based classifier — works offline without AI APIs.
class RuleBasedIntelligenceService implements IntelligenceService {
  @override
  Future<ObservationSuggestion> analyzeObservation({
    required String text,
    String? ocrText,
    String? transcription,
  }) async {
    final combined = '$text ${ocrText ?? ''} ${transcription ?? ''}'.toLowerCase();

    var category = ObservationCategory.other;
    if (combined.contains('crack') ||
        combined.contains('wall') ||
        combined.contains('structural')) {
      category = ObservationCategory.structural;
    } else if (combined.contains('electric') ||
        combined.contains('wiring') ||
        combined.contains('panel')) {
      category = ObservationCategory.electrical;
    } else if (combined.contains('water') ||
        combined.contains('leak') ||
        combined.contains('plumb')) {
      category = ObservationCategory.plumbing;
    } else if (combined.contains('safety') ||
        combined.contains('fire') ||
        combined.contains('hazard')) {
      category = ObservationCategory.safety;
    }

    var severity = ObservationSeverity.low;
    if (combined.contains('critical') ||
        combined.contains('exposed') ||
        combined.contains('urgent')) {
      severity = ObservationSeverity.critical;
    } else if (combined.contains('large') ||
        combined.contains('major') ||
        combined.contains('crack')) {
      severity = ObservationSeverity.high;
    } else if (combined.contains('minor') ||
        combined.contains('small')) {
      severity = ObservationSeverity.medium;
    }

    final title = _deriveTitle(combined);

    return ObservationSuggestion(
      title: title,
      category: category,
      severity: severity,
      status: ObservationStatus.open,
    );
  }

  @override
  Future<String> summarizeInspection({
    required List<String> observationSummaries,
    required List<String> checklistNotes,
    required String notes,
  }) async {
    final buffer = StringBuffer('Executive Summary\n\n');
    if (observationSummaries.isEmpty) {
      buffer.writeln('No observations recorded during this inspection.');
    } else {
      buffer.writeln(
        '${observationSummaries.length} observation(s) were documented.',
      );
      for (final summary in observationSummaries.take(5)) {
        buffer.writeln('• $summary');
      }
    }
    if (checklistNotes.isNotEmpty) {
      buffer.writeln('\nChecklist notes:');
      for (final note in checklistNotes.take(3)) {
        buffer.writeln('• $note');
      }
    }
    if (notes.trim().isNotEmpty) {
      buffer.writeln('\nInspector notes: $notes');
    }
    return buffer.toString().trim();
  }

  String _deriveTitle(String text) {
    if (text.contains('crack')) return 'Wall Crack';
    if (text.contains('leak')) return 'Water Leakage';
    if (text.contains('panel')) return 'Electrical Panel Issue';
    if (text.contains('mold')) return 'Mold Growth';
    final words = text.split(RegExp(r'\s+')).where((String w) => w.length > 3);
    if (words.isEmpty) return 'Field Observation';
    return words.take(3).map(_capitalize).join(' ');
  }

  String _capitalize(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
}
