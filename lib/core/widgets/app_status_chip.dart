import 'package:field_lens/app/theme/app_colors.dart';
import 'package:field_lens/app/theme/app_radius.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/extensions/context_extensions.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_status.dart';
import 'package:field_lens/features/reports/domain/entities/report_status.dart';
import 'package:material_ui/material_ui.dart';

/// Compact pill badge for statuses and severity levels.
class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    required this.label,
    required this.color,
    super.key,
    this.icon,
  });

  factory AppStatusChip.inspection(InspectionStatus status) {
    final (String label, Color color) = switch (status) {
      InspectionStatus.draft => ('Draft', AppColors.neutral500),
      InspectionStatus.inProgress => ('In Progress', AppColors.info),
      InspectionStatus.completed => ('Completed', AppColors.success),
      InspectionStatus.archived => ('Archived', AppColors.neutral700),
    };
    return AppStatusChip(label: label, color: color);
  }

  factory AppStatusChip.report(ReportStatus status) {
    final (String label, Color color) = switch (status) {
      ReportStatus.draft => ('Draft', AppColors.neutral500),
      ReportStatus.generating => ('Generating', AppColors.warning),
      ReportStatus.ready => ('Ready', AppColors.success),
      ReportStatus.shared => ('Shared', AppColors.info),
    };
    return AppStatusChip(label: label, color: color);
  }

  factory AppStatusChip.severity(String severity) {
    final normalized = severity.toLowerCase();
    final (String label, Color color) = switch (normalized) {
      'low' => ('Low', AppColors.severityLow),
      'medium' => ('Medium', AppColors.severityMedium),
      'high' => ('High', AppColors.severityHigh),
      'critical' => ('Critical', AppColors.severityCritical),
      _ => (severity, AppColors.neutral500),
    };
    return AppStatusChip(label: label, color: color);
  }

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.fullRadius,
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
