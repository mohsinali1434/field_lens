import 'package:field_lens/app/config/dependency_injection.dart';
import 'package:field_lens/app/router/app_routes.dart';
import 'package:field_lens/app/theme/app_icons.dart';
import 'package:field_lens/app/theme/app_spacing.dart';
import 'package:field_lens/core/extensions/context_extensions.dart';
import 'package:field_lens/core/services/pdf_report_service.dart';
import 'package:field_lens/core/widgets/animated_fade_slide.dart';
import 'package:field_lens/core/widgets/app_button.dart';
import 'package:field_lens/core/widgets/app_card.dart';
import 'package:field_lens/core/widgets/app_page_header.dart';
import 'package:field_lens/core/widgets/app_status_chip.dart';
import 'package:field_lens/core/widgets/empty_state.dart';
import 'package:field_lens/core/widgets/error_view.dart';
import 'package:field_lens/core/widgets/loading_view.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/repositories/inspection_repository.dart';
import 'package:field_lens/features/reports/domain/entities/report_entity.dart';
import 'package:field_lens/features/reports/domain/repositories/report_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Lists generated reports and supports PDF generation per inspection.
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportListItem {
  const _ReportListItem({
    required this.inspection,
    required this.report,
  });

  final InspectionEntity inspection;
  final ReportEntity? report;
}

class _ReportsPageState extends State<ReportsPage> {
  List<_ReportListItem>? _items;
  String? _error;
  bool _isLoading = true;
  String? _generatingInspectionId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final inspectionsResult = await sl<InspectionRepository>().getInspections();
    if (!mounted) return;

    inspectionsResult.fold(
      onSuccess: (List<InspectionEntity> inspections) async {
        final items = <_ReportListItem>[];
        for (final inspection in inspections) {
          final reportsResult = await sl<ReportRepository>().getByInspectionId(
            inspection.id,
          );
          final report = reportsResult.valueOrNull?.isNotEmpty == true
              ? reportsResult.valueOrNull!.first
              : null;
          items.add(_ReportListItem(inspection: inspection, report: report));
        }

        if (!mounted) return;
        setState(() {
          _items = items;
          _isLoading = false;
        });
      },
      onFailure: (failure) {
        setState(() {
          _error = failure.message;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _generateReport(InspectionEntity inspection) async {
    setState(() => _generatingInspectionId = inspection.id);
    final result = await sl<PdfReportService>().generateReport(
      inspectionId: inspection.id,
    );
    if (!mounted) return;

    setState(() => _generatingInspectionId = null);
    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report generated for ${inspection.title}')),
        );
        _load();
      },
      onFailure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  Future<void> _previewReport(String path) async {
    final result = await sl<PdfReportService>().preview(path);
    if (!mounted) return;

    result.fold(
      onSuccess: (_) {},
      onFailure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Column(
        children: <Widget>[
          AppPageHeader(
            title: 'Reports',
            subtitle: 'Generate and preview PDF reports',
            compact: true,
          ),
          Expanded(child: LoadingView(message: 'Loading reports...')),
        ],
      );
    }

    if (_error != null) {
      return Column(
        children: <Widget>[
          const AppPageHeader(
            title: 'Reports',
            subtitle: 'Generate and preview PDF reports',
            compact: true,
          ),
          Expanded(child: ErrorView(message: _error!, onRetry: _load)),
        ],
      );
    }

    final items = _items ?? <_ReportListItem>[];
    if (items.isEmpty) {
      return const Column(
        children: <Widget>[
          AppPageHeader(
            title: 'Reports',
            subtitle: 'Generate and preview PDF reports',
            compact: true,
          ),
          Expanded(
            child: EmptyState(
              title: 'No reports yet',
              message:
                  'Complete an inspection to generate a professional PDF report.',
              icon: AppIcons.reports,
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        itemCount: items.length + 1,
        separatorBuilder: (_, int index) {
          if (index == 0) return const SizedBox.shrink();
          return const SizedBox(height: AppSpacing.sm);
        },
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AnimatedFadeSlide(
                child: const AppPageHeader(
                  title: 'Reports',
                  subtitle: 'Generate and preview PDF reports',
                  compact: true,
                ),
              ),
            );
          }

          final item = items[index - 1];
          final isGenerating = _generatingInspectionId == item.inspection.id;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AnimatedFadeSlide(
              index: index,
              child: AppCard(
              elevated: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          item.inspection.title,
                          style: context.textTheme.titleMedium,
                        ),
                      ),
                      if (item.report != null)
                        AppStatusChip.report(item.report!.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.inspection.siteName,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (item.report != null) ...<Widget>[
                    if (item.report!.generatedAt != null)
                      Text(
                        'Generated ${DateFormat.yMMMd().format(item.report!.generatedAt!.toLocal())}',
                        style: context.textTheme.bodySmall,
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: <Widget>[
                        if (item.report!.filePath != null)
                          AppButton(
                            label: 'Preview',
                            variant: AppButtonVariant.outlined,
                            onPressed: () =>
                                _previewReport(item.report!.filePath!),
                          ),
                        const SizedBox(width: AppSpacing.sm),
                        AppButton(
                          label: 'Regenerate',
                          variant: AppButtonVariant.secondary,
                          isLoading: isGenerating,
                          onPressed: isGenerating
                              ? null
                              : () => _generateReport(item.inspection),
                        ),
                      ],
                    ),
                  ] else
                    AppButton(
                      label: 'Generate PDF',
                      icon: AppIcons.reports,
                      isLoading: isGenerating,
                      onPressed: isGenerating
                          ? null
                          : () => _generateReport(item.inspection),
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    onPressed: () => context.push(
                      AppRoutes.inspectionDetailPath(item.inspection.id),
                    ),
                    child: const Text('Open inspection'),
                  ),
                ],
              ),
            ),
            ),
          );
        },
      ),
    );
  }
}
