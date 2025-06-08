import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:dishtv_agent_tracker/domain/entities/monthly_summary.dart';
import 'package:dishtv_agent_tracker/domain/entities/daily_entry.dart';
import 'package:dishtv_agent_tracker/core/constants/app_constants.dart';

class PdfService {
  // Generate a PDF report for a monthly summary
  Future<String> generateMonthlyReport(MonthlySummary summary) async {
    // Create a PDF document
    final pdf = pw.Document();
    
    // Add pages to the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(summary),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildSummarySection(summary),
          pw.SizedBox(height: 20),
          _buildSalarySection(summary),
          pw.SizedBox(height: 20),
          _buildDailyEntriesTable(summary.entries),
        ],
      ),
    );
    
    // Save the PDF to a file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/monthly_report_${summary.month}_${summary.year}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file.path;
  }
  
  // Build the header section
  pw.Widget _buildHeader(MonthlySummary summary) {
    return pw.Header(
      level: 0,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DishTV Agent Performance Report',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            summary.formattedMonthYear,
            style: const pw.TextStyle(
              fontSize: 18,
            ),
          ),
          pw.Divider(),
        ],
      ),
    );
  }
  
  // Build the summary section
  pw.Widget _buildSummarySection(MonthlySummary summary) {
    final formatter = NumberFormat('#,##0.00');
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Monthly Summary',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            _buildSummaryCard(
              'Total Login Hours',
              '${formatter.format(summary.totalLoginHours)} hrs',
              width: 250,
            ),
            pw.SizedBox(width: 20),
            _buildSummaryCard(
              'Total Calls',
              '${summary.totalCalls}',
              width: 250,
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            _buildSummaryCard(
              'Avg. Daily Login Hours',
              '${formatter.format(summary.averageDailyLoginHours)} hrs',
              width: 250,
            ),
            pw.SizedBox(width: 20),
            _buildSummaryCard(
              'Avg. Daily Calls',
              '${formatter.format(summary.averageDailyCalls)}',
              width: 250,
            ),
          ],
        ),
      ],
    );
  }
  
  // Build a summary card
  pw.Widget _buildSummaryCard(String title, String value, {required double width}) {
    return pw.Container(
      width: width,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(
              color: PdfColors.grey700,
              fontSize: 12,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  // Build the salary section
  pw.Widget _buildSalarySection(MonthlySummary summary) {
    final formatter = NumberFormat('#,##0.00');
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Salary Calculation',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Column(
            children: [
              _buildSalaryRow(
                'Base Salary (₹${AppConstants.baseRatePerCall} per call)',
                '₹${formatter.format(summary.baseSalary)}',
              ),
              pw.Divider(),
              _buildSalaryRow(
                'Bonus (${summary.isBonusAchieved ? 'Achieved' : 'Not Achieved'})',
                '₹${formatter.format(summary.bonusAmount)}',
                highlight: summary.isBonusAchieved,
              ),
              pw.SizedBox(height: 5),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                color: PdfColors.grey100,
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Bonus Criteria: ${AppConstants.bonusCallTarget}+ calls & ${AppConstants.bonusHourTarget}+ hours',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.Divider(),
              _buildSalaryRow(
                'Total Salary',
                '₹${formatter.format(summary.totalSalary)}',
                isBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Build a salary row
  pw.Widget _buildSalaryRow(String label, String amount, {bool highlight = false, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: isBold ? pw.FontWeight.bold : null,
              ),
            ),
          ),
          pw.Text(
            amount,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : null,
              color: highlight ? PdfColors.green700 : null,
            ),
          ),
        ],
      ),
    );
  }
  
  // Build the daily entries table
  pw.Widget _buildDailyEntriesTable(List<DailyEntry> entries) {
    // Sort entries by date
    final sortedEntries = List<DailyEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Daily Entries',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2), // Date
            1: const pw.FlexColumnWidth(2), // Login Time
            2: const pw.FlexColumnWidth(1), // Calls
          },
          children: [
            // Table header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('Date', isHeader: true),
                _buildTableCell('Login Time', isHeader: true),
                _buildTableCell('Calls', isHeader: true),
              ],
            ),
            // Table rows
            ...sortedEntries.map((entry) {
              final dateFormatter = DateFormat('dd MMM yyyy');
              return pw.TableRow(
                children: [
                  _buildTableCell(dateFormatter.format(entry.date)),
                  _buildTableCell(entry.formattedLoginTime),
                  _buildTableCell('${entry.callCount}'),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }
  
  // Build a table cell
  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }
  
  // Build the footer
  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(
              color: PdfColors.grey700,
              fontSize: 10,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated on ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
            style: const pw.TextStyle(
              color: PdfColors.grey700,
              fontSize: 10,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Developed by ${AppConstants.appDeveloper}',
            style: const pw.TextStyle(
              color: PdfColors.grey700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

