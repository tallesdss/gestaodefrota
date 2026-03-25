import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/financial_entry.dart';

class ReportGenerator {
  static Future<void> generateFinancialReport(List<FinancialEntry> entries) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('RELATÓRIO FINANCEIRO - GESTÃO DE FROTA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Data', 'Tipo', 'Categoria', 'Descrição', 'Valor'],
            data: entries.map((e) => [
              '${e.date.day}/${e.date.month}/${e.date.year}',
              e.type == FinancialType.income ? 'RECEITA' : 'DESPESA',
              e.category,
              e.description,
              'R\$ ${e.amount.toStringAsFixed(2)}'
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Total: R\$ ${entries.fold(0.0, (sum, e) => e.type == FinancialType.income ? sum + e.amount : sum - e.amount).toStringAsFixed(2)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
