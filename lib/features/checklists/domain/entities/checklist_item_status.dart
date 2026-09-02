enum ChecklistItemStatus {
  notStarted('not_started'),
  passed('passed'),
  failed('failed'),
  notApplicable('not_applicable');

  const ChecklistItemStatus(this.value);

  final String value;

  static ChecklistItemStatus fromValue(String value) =>
      ChecklistItemStatus.values.firstWhere(
        (ChecklistItemStatus status) => status.value == value,
        orElse: () => ChecklistItemStatus.notStarted,
      );
}
