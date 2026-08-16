import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/financial_entry.dart';

class ReportGenerator {
  static Future<void> generateFinancialReport(
    List<FinancialEntry> entries,
  ) async {
    final pdf = pw.Document();

    final totalIncome = entries
        .where((e) => e.type == FinancialType.income)
        .fold(0.0, (sum, e) => sum + e.amount);

    final totalExpense = entries
        .where((e) => e.type == FinancialType.expense)
        .fold(0.0, (sum, e) => sum + e.amount);

    final netProfit = totalIncome - totalExpense;

    final totalPaid = entries
        .where((e) => e.isPaid)
        .fold(0.0, (sum, e) => sum + e.amount);

    final totalPending = entries
        .where((e) => !e.isPaid)
        .fold(0.0, (sum, e) => sum + e.amount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'RELATÓRIO FINANCEIRO CONSOLIDADO',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
                ),
                pw.Text(
                  'Emitido em: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Resumo Financeiro
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('RECEITA TOTAL', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    pw.Text('R\$ ${totalIncome.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('DESPESA TOTAL', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    pw.Text('R\$ ${totalExpense.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SALDO LÍQUIDO', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    pw.Text('R\$ ${netProfit.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: netProfit >= 0 ? PdfColors.blue800 : PdfColors.red800)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('TOTAL PAGO', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    pw.Text('R\$ ${totalPaid.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('PENDÊNCIAS', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    pw.Text('R\$ ${totalPending.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.orange800)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Tabela Analítica
          pw.TableHelper.fromTextArray(
            headers: ['Data', 'Tipo', 'Categoria', 'Descrição', 'Status', 'Valor (R\$)'],
            data: entries
                .map(
                  (e) => [
                    '${e.date.day.toString().padLeft(2, '0')}/${e.date.month.toString().padLeft(2, '0')}/${e.date.year}',
                    e.type == FinancialType.income ? 'RECEITA' : 'DESPESA',
                    e.category,
                    e.description,
                    e.isPaid ? 'PAGO' : 'PENDENTE',
                    'R\$ ${e.amount.toStringAsFixed(2)}',
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerLeft,
              4: pw.Alignment.center,
              5: pw.Alignment.centerRight,
            },
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
