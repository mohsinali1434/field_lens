import 'package:equatable/equatable.dart';

/// Key-value application setting stored locally.
class SettingEntity extends Equatable {
  const SettingEntity({
    required this.key,
    required this.value,
    required this.updatedAt,
  });

  final String key;
  final String value;
  final DateTime updatedAt;

  @override
  List<Object?> get props => <Object?>[key, value, updatedAt];
}
