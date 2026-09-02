import 'package:equatable/equatable.dart';
import 'package:field_lens/core/domain/sync_metadata.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';

/// Domain representation of a field inspection.
class InspectionEntity extends Equatable {
  const InspectionEntity({
    required this.id,
    required this.title,
    required this.clientName,
    required this.siteName,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
    this.completedAt,
    this.latitude,
    this.longitude,
    this.address,
    this.weatherSummary,
    this.notes,
    this.templateId,
    this.sync = const SyncMetadata(),
  });

  final String id;
  final String title;
  final String clientName;
  final String siteName;
  final String description;
  final InspectionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? weatherSummary;
  final String? notes;
  final String? templateId;
  final SyncMetadata sync;

  InspectionEntity copyWith({
    String? id,
    String? title,
    String? clientName,
    String? siteName,
    String? description,
    InspectionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    double? latitude,
    double? longitude,
    String? address,
    String? weatherSummary,
    String? notes,
    String? templateId,
    SyncMetadata? sync,
  }) {
    return InspectionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      clientName: clientName ?? this.clientName,
      siteName: siteName ?? this.siteName,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      weatherSummary: weatherSummary ?? this.weatherSummary,
      notes: notes ?? this.notes,
      templateId: templateId ?? this.templateId,
      sync: sync ?? this.sync,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    clientName,
    siteName,
    description,
    status,
    createdAt,
    updatedAt,
    startedAt,
    completedAt,
    latitude,
    longitude,
    address,
    weatherSummary,
    notes,
    templateId,
    sync,
  ];
}
