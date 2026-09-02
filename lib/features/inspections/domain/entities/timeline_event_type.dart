enum TimelineEventType {
  photoCaptured('photo_captured'),
  observationCreated('observation_created'),
  voiceNoteRecorded('voice_note_recorded'),
  checklistItemFailed('checklist_item_failed'),
  observationResolved('observation_resolved'),
  inspectionStarted('inspection_started'),
  inspectionCompleted('inspection_completed'),
  noteAdded('note_added'),
  other('other');

  const TimelineEventType(this.value);

  final String value;

  static TimelineEventType fromValue(String value) =>
      TimelineEventType.values.firstWhere(
        (TimelineEventType type) => type.value == value,
        orElse: () => TimelineEventType.other,
      );
}
