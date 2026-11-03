import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  static Future<Uint8List> generateCatalog({
    required String title,
    required List<String> items,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          padding: const pw.EdgeInsets.only(bottom: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.blueGrey700, width: 2),
            ),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Catálogo: $title',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
              pw.Text(
                'Total: ${items.length} títulos',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ),
        build: (context) => [
          pw.Wrap(
            spacing: 16,
            runSpacing: 6,
            children: List.generate(items.length, (index) {
              return pw.SizedBox(
                width: 250, // Ajuste para 2 columnas en A4
                child: pw.Text(
                  '${index + 1}. ${items[index]}',
                  style: const pw.TextStyle(fontSize: 10),
                  maxLines: 1,
                  overflow: pw.TextOverflow.clip,
                ),
              );
            }),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
