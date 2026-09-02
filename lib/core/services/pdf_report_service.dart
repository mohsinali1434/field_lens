import 'dart:io';

import 'package:field_lens/core/errors/failures.dart';
import 'package:field_lens/core/utils/result.dart';
import 'package:field_lens/features/checklists/domain/entities/checklist_entities.dart';
import 'package:field_lens/features/inspections/domain/entities/inspection_entity.dart';
import 'package:field_lens/features/inspections/domain/repositories/inspection_repository.dart';
import 'package:field_lens/features/observations/domain/entities/observation_entity.dart';
import 'package:field_lens/features/observations/domain/repositories/observation_repository.dart';
import 'package:field_lens/features/reports/domain/entities/report_entity.dart';
import 'package:field_lens/features/reports/domain/entities/report_status.dart';
import 'package:field_lens/features/reports/domain/repositories/report_repository.dart';
import 'package:field_lens/features/checklists/domain/repositories/checklist_repository.dart';
import 'package:field_lens/features/media/domain/entities/media_entity.dart';
import 'package:field_lens/features/media/domain/repositories/media_repository.dart';
import 'package:field_lens/features/inspections/domain/entities/timeline_event_entity.dart';
import 'package:field_lens/features/inspections/domain/repositories/timeline_repository.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Generates on-device PDF inspection reports.
class PdfReportService {
  PdfReportService({
    required InspectionRepository inspectionRepository,
    required ObservationRepository observationRepository,
    required ChecklistRepository checklistRepository,
    required ReportRepository reportRepository,
  }) : _inspectionRepository = inspectionRepository,
       _observationRepository = observationRepository,
       _checklistRepository = checklistRepository,
       _reportRepository = reportRepository;

  final InspectionRepository _inspectionRepository;
  final ObservationRepository _observationRepository;
  final ChecklistRepository _checklistRepository;
  final ReportRepository _reportRepository;

  Future<Result<String>> generateReport({
    required String inspectionId,
    String inspectorName = 'Inspector',
    String companyName = 'FieldLens',
    String? signaturePath,
    String? executiveSummary,
  }) async {
    try {
      final inspectionResult = await _inspectionRepository.getInspectionById(
        inspectionId,
      );
      if (inspectionResult.isFailure) {
        return Error<String>(inspectionResult.failureOrNull!);
      }
      final inspection = inspectionResult.valueOrNull!;

      final observationsResult = await _observationRepository.getByInspectionId(
        inspectionId,
      );
      final observations = observationsResult.valueOrNull ?? <ObservationEntity>[];

      final checklistResult = await _checklistRepository.getResultsByInspectionId(
        inspectionId,
      );
      final checklist = checklistResult.valueOrNull ?? <ChecklistResultEntity>[];

      final pdf = pw.Document();
      final dateLabel = DateFormat.yMMMMd().format(inspection.updatedAt.toLocal());

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => <pw.Widget>[
            pw.Header(level: 0, child: pw.Text('FIELDLENS')),
            pw.Text('INSPECTION REPORT', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 12),
            pw.Text('Inspection: ${inspection.title}'),
            pw.Text('Client: ${inspection.clientName}'),
            pw.Text('Site: ${inspection.siteName}'),
            pw.Text('Date: $dateLabel'),
            pw.Text('Inspector: $inspectorName'),
            pw.Text('Company: $companyName'),
            pw.Divider(),
            pw.Header(level: 1, child: pw.Text('EXECUTIVE SUMMARY')),
            pw.Text(executiveSummary ?? inspection.description),
            pw.SizedBox(height: 12),
            pw.Header(level: 1, child: pw.Text('CHECKLIST')),
            ...checklist.map(
              (ChecklistResultEntity item) => pw.Text(
                '${item.title}: ${item.status.value}',
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Header(level: 1, child: pw.Text('OBSERVATIONS')),
            ...observations.map((ObservationEntity obs) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  pw.Text(
                    obs.title,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Severity: ${obs.severity.value.toUpperCase()} | '
                    'Status: ${obs.status.value.toUpperCase()}',
                  ),
                  pw.Text(obs.description),
                  pw.SizedBox(height: 8),
                ],
              );
            }),
            if (signaturePath != null && File(signaturePath).existsSync()) ...<pw.Widget>[
              pw.SizedBox(height: 16),
              pw.Text('SIGNATURE'),
              pw.Image(
                pw.MemoryImage(File(signaturePath).readAsBytesSync()),
                width: 180,
                height: 80,
              ),
            ],
            pw.SizedBox(height: 16),
            pw.Text('REPORT GENERATED ${DateTime.now().toLocal()}'),
          ],
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final reportsDir = Directory('${dir.path}/reports');
      if (!reportsDir.existsSync()) {
        await reportsDir.create(recursive: true);
      }
      final file = File('${reportsDir.path}/report_$inspectionId.pdf');
      await file.writeAsBytes(await pdf.save());

      final reports = await _reportRepository.getByInspectionId(inspectionId);
      final existing = reports.valueOrNull?.isNotEmpty == true
          ? reports.valueOrNull!.first
          : ReportEntity(
              id: inspectionId,
              inspectionId: inspectionId,
              status: ReportStatus.ready,
              createdAt: DateTime.now().toUtc(),
              updatedAt: DateTime.now().toUtc(),
            );

      await _reportRepository.saveReport(
        ReportEntity(
          id: existing.id,
          inspectionId: inspectionId,
          status: ReportStatus.ready,
          filePath: file.path,
          createdAt: existing.createdAt,
          updatedAt: DateTime.now().toUtc(),
          generatedAt: DateTime.now().toUtc(),
        ),
      );

      return Success<String>(file.path);
    } on Object catch (error) {
      return Error<String>(
        PdfGenerationFailure(message: 'PDF generation failed: $error'),
      );
    }
  }

  Future<Result<void>> preview(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      await Printing.layoutPdf(onLayout: (_) async => bytes);
      return const Success<void>(null);
    } on Object catch (error) {
      return Error<void>(
        PdfGenerationFailure(message: 'Preview failed: $error'),
      );
    }
  }
}
