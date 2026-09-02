enum ObservationCategory {
  structural('structural'),
  electrical('electrical'),
  plumbing('plumbing'),
  safety('safety'),
  maintenance('maintenance'),
  cleanliness('cleanliness'),
  equipment('equipment'),
  other('other');

  const ObservationCategory(this.value);

  final String value;

  static ObservationCategory fromValue(String value) =>
      ObservationCategory.values.firstWhere(
        (ObservationCategory category) => category.value == value,
        orElse: () => ObservationCategory.other,
      );
}

enum ObservationSeverity {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  const ObservationSeverity(this.value);

  final String value;

  static ObservationSeverity fromValue(String value) =>
      ObservationSeverity.values.firstWhere(
        (ObservationSeverity severity) => severity.value == value,
        orElse: () => ObservationSeverity.low,
      );
}

enum ObservationStatus {
  open('open'),
  inProgress('in_progress'),
  resolved('resolved'),
  ignored('ignored');

  const ObservationStatus(this.value);

  final String value;

  static ObservationStatus fromValue(String value) =>
      ObservationStatus.values.firstWhere(
        (ObservationStatus status) => status.value == value,
        orElse: () => ObservationStatus.open,
      );
}
