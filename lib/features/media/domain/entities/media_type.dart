enum MediaType {
  image('image'),
  audio('audio'),
  document('document');

  const MediaType(this.value);

  final String value;

  static MediaType fromValue(String value) => MediaType.values.firstWhere(
    (MediaType type) => type.value == value,
    orElse: () => MediaType.image,
  );
}
