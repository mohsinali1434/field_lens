enum ReportStatus {
  draft('draft'),
  generating('generating'),
  ready('ready'),
  shared('shared');

  const ReportStatus(this.value);

  final String value;

  static ReportStatus fromValue(String value) => ReportStatus.values.firstWhere(
    (ReportStatus status) => status.value == value,
    orElse: () => ReportStatus.draft,
  );
}
