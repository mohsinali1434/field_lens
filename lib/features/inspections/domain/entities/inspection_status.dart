enum InspectionStatus {
  draft('draft'),
  inProgress('in_progress'),
  completed('completed'),
  archived('archived');

  const InspectionStatus(this.value);

  final String value;

  static InspectionStatus fromValue(String value) =>
      InspectionStatus.values.firstWhere(
        (InspectionStatus status) => status.value == value,
        orElse: () => InspectionStatus.draft,
      );
}
