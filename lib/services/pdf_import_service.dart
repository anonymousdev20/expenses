import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/expense.dart';

class ParsedTransaction {
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final String notes;

  ParsedTransaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.notes,
  });
}

class PdfImportService {
  // Date formats commonly found in bank statements
  static final List<DateFormat> _dateFormats = [
    DateFormat('dd/MM/yyyy'),
    DateFormat('dd-MM-yyyy'),
    DateFormat('MM/dd/yyyy'),
    DateFormat('dd MMM yyyy'),
    DateFormat('dd MMM yy'),
    DateFormat('yyyy-MM-dd'),
    DateFormat('d/M/yyyy'),
    DateFormat('d/M/yy'),
  ];

  // Regex patterns
  static final _amountPattern = RegExp(
    r'(?:Rs\.?|INR|₹|\$|USD)?\s*([\d,]+(?:\.\d{1,2})?)\s*(?:Dr|Cr|DR|CR)?',
  );
  static final _datePattern = RegExp(
    r'\b(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}|\d{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+\d{2,4}|\d{4}-\d{2}-\d{2})\b',
    caseSensitive: false,
  );
  static final _creditKeywords = RegExp(
    r'\b(credit|cr|salary|income|received|deposit|refund|cashback|interest earned)\b',
    caseSensitive: false,
  );

  static Future<List<ParsedTransaction>> parsePdf(Uint8List bytes) async {
    final document = PdfDocument(inputBytes: bytes);
    final extractor = PdfTextExtractor(document);
    final fullText = extractor.extractText();
    document.dispose();

    return _parseText(fullText);
  }

  static List<ParsedTransaction> _parseText(String text) {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    final results = <ParsedTransaction>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Must have a date and an amount to be a transaction line
      final dateMatch = _datePattern.firstMatch(line);
      if (dateMatch == null) continue;

      final date = _parseDate(dateMatch.group(0)!);
      if (date == null) continue;

      // Find all amounts in the line
      final amounts = _amountPattern.allMatches(line)
          .map((m) => _parseAmount(m.group(1)!))
          .where((a) => a != null && a > 0)
          .cast<double>()
          .toList();

      if (amounts.isEmpty) continue;

      // Use the largest amount (avoids picking up small reference numbers)
      final amount = amounts.reduce((a, b) => a > b ? a : b);
      if (amount < 1) continue;

      // Extract description: remove date and amount tokens, clean up
      String desc = line
          .replaceAll(_datePattern, '')
          .replaceAll(_amountPattern, '')
          .replaceAll(RegExp(r'\b(Dr|Cr|DR|CR)\b'), '')
          .replaceAll(RegExp(r'\s{2,}'), ' ')
          .trim();

      if (desc.isEmpty) {
        // Try next line as description
        desc = i + 1 < lines.length ? lines[i + 1].trim() : 'Transaction';
      }
      if (desc.length > 60) desc = desc.substring(0, 60).trim();
      if (desc.isEmpty) desc = 'Transaction';

      final isIncome = _creditKeywords.hasMatch(line) ||
          line.toUpperCase().contains('CR') && !line.toUpperCase().contains('DEBIT');

      results.add(ParsedTransaction(
        title: desc,
        amount: amount,
        date: date,
        isIncome: isIncome,
        notes: 'Imported from PDF',
      ));
    }

    // Sort by date descending
    results.sort((a, b) => b.date.compareTo(a.date));
    return results;
  }

  static DateTime? _parseDate(String raw) {
    for (final fmt in _dateFormats) {
      try {
        return fmt.parseStrict(raw.trim());
      } catch (_) {}
    }
    return null;
  }

  static double? _parseAmount(String raw) {
    try {
      return double.parse(raw.replaceAll(',', ''));
    } catch (_) {
      return null;
    }
  }

  static List<Expense> toExpenses(List<ParsedTransaction> parsed) {
    return parsed.map((t) => Expense(
      title: t.title,
      amount: t.amount,
      category: t.isIncome ? 'Other Income' : 'Food & Dining',
      date: t.date,
      paymentMethod: 'Bank Transfer',
      notes: t.notes,
      isIncome: t.isIncome,
    )).toList();
  }
}
