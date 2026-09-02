import 'package:equatable/equatable.dart';
import 'package:field_lens/core/domain/sync_metadata.dart';
import 'package:field_lens/features/checklists/domain/entities/checklist_item_status.dart';

/// Reusable checklist template definition.
class ChecklistTemplateEntity extends Equatable {
  const ChecklistTemplateEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.sync = const SyncMetadata(),
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncMetadata sync;

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    description,
    category,
    createdAt,
    updatedAt,
    sync,
  ];
}

/// Item belonging to a checklist template.
class ChecklistTemplateItemEntity extends Equatable {
  const ChecklistTemplateItemEntity({
    required this.id,
    required this.templateId,
    required this.title,
    required this.description,
    required this.required,
    required this.sortOrder,
    this.sync = const SyncMetadata(),
  });

  final String id;
  final String templateId;
  final String title;
  final String description;
  final bool required;
  final int sortOrder;
  final SyncMetadata sync;

  @override
  List<Object?> get props => <Object?>[
    id,
    templateId,
    title,
    description,
    required,
    sortOrder,
    sync,
  ];
}

/// Checklist execution result for a specific inspection item.
class ChecklistResultEntity extends Equatable {
  const ChecklistResultEntity({
    required this.id,
    required this.inspectionId,
    required this.templateId,
    required this.itemId,
    required this.title,
    required this.description,
    required this.required,
    required this.status,
    required this.sortOrder,
    this.notes,
    this.completedAt,
    this.sync = const SyncMetadata(),
  });

  final String id;
  final String inspectionId;
  final String templateId;
  final String itemId;
  final String title;
  final String description;
  final bool required;
  final ChecklistItemStatus status;
  final String? notes;
  final DateTime? completedAt;
  final int sortOrder;
  final SyncMetadata sync;

  @override
  List<Object?> get props => <Object?>[
    id,
    inspectionId,
    templateId,
    itemId,
    title,
    description,
    required,
    status,
    notes,
    completedAt,
    sortOrder,
    sync,
  ];
}
