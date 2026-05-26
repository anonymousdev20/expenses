import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/expense.dart';
import '../constants/app_constants.dart';

class PdfService {
  static Future<void> exportExpenses({
    required BuildContext context,
    required List<Expense> expenses,
    required String title,
  }) async {
    final pdf = pw.Document();
    final fmt = NumberFormat('#,##,##0.00', 'en_IN');
    final sym = 'INR'; // Use text instead of ₹ symbol for PDF font compatibility

    // Load a font that supports rupee symbol
    pw.Font? ttf;
    try {
      final fontData = await PdfGoogleFonts.notoSansRegular();
      ttf = fontData;
    } catch (_) {
      ttf = null;
    }
    final pw.TextStyle baseStyle = pw.TextStyle(font: ttf, fontSize: 9);
    final pw.TextStyle boldStyle = pw.TextStyle(font: ttf, fontSize: 9, fontWeight: pw.FontWeight.bold);

    final totalIncome = expenses
        .where((e) => e.isIncome)
        .fold(0.0, (sum, e) => sum + e.amount);
    final totalExpense = expenses
        .where((e) => !e.isIncome)
        .fold(0.0, (sum, e) => sum + e.amount);
    final balance = totalIncome - totalExpense;

    // Category breakdown
    final Map<String, double> categoryTotals = {};
    for (final e in expenses.where((e) => !e.isIncome)) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ExpensePro',
                        style: pw.TextStyle(
                            font: ttf,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800)),
                    pw.Text(title,
                        style: pw.TextStyle(
                            font: ttf, fontSize: 13, color: PdfColors.grey700)),
                  ],
                ),
                pw.Text(
                  'Generated: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                  style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
            pw.Divider(color: PdfColors.blue800, thickness: 2),
            pw.SizedBox(height: 8),
          ],
        ),
        build: (context) => [
          // Summary Cards
          pw.Row(
            children: [
              _summaryBox('Total Income', '$sym ${fmt.format(totalIncome)}',
                  PdfColors.green700, ttf),
              pw.SizedBox(width: 12),
              _summaryBox('Total Expenses', '$sym ${fmt.format(totalExpense)}',
                  PdfColors.red700, ttf),
              pw.SizedBox(width: 12),
              _summaryBox(
                  'Balance',
                  '$sym ${fmt.format(balance.abs())}${balance < 0 ? ' (deficit)' : ''}',
                  balance >= 0 ? PdfColors.blue800 : PdfColors.orange800, ttf),
            ],
          ),

          pw.SizedBox(height: 20),

          // Category Breakdown
          if (sortedCategories.isNotEmpty) ...[
            pw.Text('Spending by Category',
                style: pw.TextStyle(
                    font: ttf,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue800),
                  children: [
                    _tableHeader('Category', ttf),
                    _tableHeader('Amount', ttf),
                    _tableHeader('% of Total', ttf),
                  ],
                ),
                ...sortedCategories.map((entry) {
                  final pct = totalExpense > 0
                      ? (entry.value / totalExpense * 100).toStringAsFixed(1)
                      : '0.0';
                  return pw.TableRow(children: [
                    _tableCell(entry.key, baseStyle),
                    _tableCell('$sym ${fmt.format(entry.value)}', baseStyle),
                    _tableCell('$pct%', baseStyle),
                  ]);
                }),
              ],
            ),
            pw.SizedBox(height: 20),
          ],

          // Transactions Table
          pw.Text('All Transactions',
              style: pw.TextStyle(
                  font: ttf,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue800),
                children: [
                  _tableHeader('Title', ttf),
                  _tableHeader('Category', ttf),
                  _tableHeader('Date', ttf),
                  _tableHeader('Type', ttf),
                  _tableHeader('Amount', ttf),
                ],
              ),
              ...expenses.map((e) {
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: expenses.indexOf(e) % 2 == 0
                        ? PdfColors.grey100
                        : PdfColors.white,
                  ),
                  children: [
                    _tableCell(e.title, baseStyle),
                    _tableCell(e.category, baseStyle),
                    _tableCell(DateFormat('dd MMM yy').format(e.date), baseStyle),
                    _tableCellColored(
                        e.isIncome ? 'Income' : 'Expense',
                        e.isIncome ? PdfColors.green700 : PdfColors.red700,
                        boldStyle),
                    _tableCellColored(
                        '${e.isIncome ? '+' : '-'}$sym ${fmt.format(e.amount)}',
                        e.isIncome ? PdfColors.green700 : PdfColors.red700,
                        boldStyle),
                  ],
                );
              }),
            ],
          ),
        ],
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('ExpensePro — Expense Report',
                style: pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.grey500)),
            pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.grey500)),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'ExpensePro_${DateFormat('yyyy_MM').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _summaryBox(String label, String value, PdfColor color, pw.Font? font) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: pw.TextStyle(font: font, fontSize: 9, color: PdfColors.grey600)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(
                    font: font,
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: color)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _tableHeader(String text, pw.Font? font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text,
          style: pw.TextStyle(
              font: font,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white)),
    );
  }

  static pw.Widget _tableCell(String text, pw.TextStyle style) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: style),
    );
  }

  static pw.Widget _tableCellColored(String text, PdfColor color, pw.TextStyle baseStyle) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text,
          style: baseStyle.copyWith(color: color)),
    );
  }
}
