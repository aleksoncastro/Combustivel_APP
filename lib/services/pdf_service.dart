import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../modelos/abastecimento.dart';

// Conditional import: o compilador escolhe o helper correto por plataforma.
import 'pdf_helper_stub.dart'
    if (dart.library.html) 'pdf_helper_web.dart'
    if (dart.library.io) 'pdf_helper_native.dart';

class PdfService {
  /// Gera o PDF a partir dos dados filtrados e entrega conforme a plataforma:
  /// - **Windows**: abre no leitor padrão (Edge, Adobe, etc.)
  /// - **Mobile**: abre o menu nativo de compartilhamento (WhatsApp, Drive, etc.)
  /// - **Web**: dispara o download direto no navegador
  Future<void> gerarECompartilharPdf(List<Abastecimento> abastecimentos) async {
    final pdf = pw.Document();

    double totalGasto = 0;
    double totalLitros = 0;
    double totalKm = 0;

    for (var abast in abastecimentos) {
      totalGasto += abast.valorTotal;
      totalLitros += abast.litros;
      if (abast.mediaConsumo != null && abast.kmAnterior != null) {
        totalKm += (abast.kmAtual - abast.kmAnterior!);
      }
    }

    final mediaGeral = totalLitros > 0 && totalKm > 0 ? totalKm / totalLitros : 0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildTable(abastecimentos),
            pw.SizedBox(height: 20),
            _buildFooter(totalGasto, mediaGeral),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    final fileName = 'relatorio_abastecimentos_${DateTime.now().millisecondsSinceEpoch}.pdf';

    // Delega a entrega para o helper específico da plataforma
    await entregarPdf(bytes, fileName);
  }

  pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Relatório de Abastecimentos',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Gerado em: ${DateTime.now().toLocal().toString().split('.')[0]}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
      ],
    );
  }

  pw.Widget _buildTable(List<Abastecimento> abastecimentos) {
    final headers = ['Data', 'Veículo', 'Posto', 'Litros', 'Preço/L', 'Total'];

    final data = abastecimentos.map((a) {
      return [
        a.data,
        a.nomeVeiculo,
        a.posto,
        '${a.litros.toStringAsFixed(2)} L',
        'R\$ ${a.valorPorLitro.toStringAsFixed(2)}',
        'R\$ ${a.valorTotal.toStringAsFixed(2)}',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildFooter(double totalGasto, double mediaGeral) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Média Geral: ${mediaGeral > 0 ? '${mediaGeral.toStringAsFixed(2)} km/L' : '--'}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Total Gasto: R\$ ${totalGasto.toStringAsFixed(2)}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PDF individual – comprovante de um único abastecimento
  // ─────────────────────────────────────────────────────────────────────────

  /// Gera um comprovante detalhado de um único abastecimento e entrega
  /// conforme a plataforma (igual ao comportamento do relatório em lista).
  Future<void> gerarPdfIndividual(Abastecimento a) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context ctx) => _buildComprovanteIndividual(a),
      ),
    );

    final bytes = await pdf.save();
    final fileName = 'comprovante_abastecimento_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await entregarPdf(bytes, fileName);
  }

  pw.Widget _buildComprovanteIndividual(Abastecimento a) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // ── Cabeçalho ──────────────────────────────────────────────────────
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: const pw.BoxDecoration(
            color: PdfColors.blue800,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'Comprovante de Abastecimento',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                a.data,
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.white),
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 24),

        // ── Destaque do valor total ────────────────────────────────────────
        pw.Center(
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 32),
            decoration: const pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'TOTAL PAGO',
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.blue800,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'R\$ ${a.valorTotal.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
              ],
            ),
          ),
        ),

        pw.SizedBox(height: 28),

        // ── Tabela de detalhes ─────────────────────────────────────────────
        pw.Text(
          'Detalhes',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        pw.TableHelper.fromTextArray(
          headers: ['Campo', 'Valor'],
          data: [
            ['Veículo', a.nomeVeiculo],
            ['Combustível', a.tipoCombustivel],
            ['Posto', a.posto],
            ['Litros', '${a.litros.toStringAsFixed(3)} L'],
            ['Preço por litro', 'R\$ ${a.valorPorLitro.toStringAsFixed(3)}'],
            ['Quilometragem atual', '${a.kmAtual.toStringAsFixed(0)} km'],
            if (a.kmAnterior != null)
              ['Quilometragem anterior', '${a.kmAnterior!.toStringAsFixed(0)} km'],
            if (a.mediaConsumo != null)
              ['Média de consumo', '${a.mediaConsumo!.toStringAsFixed(2)} km/L'],
          ],
          border: pw.TableBorder.all(color: PdfColors.grey300),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
          oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
          cellHeight: 28,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
          },
        ),

        pw.SizedBox(height: 28),

        // ── Rodapé ────────────────────────────────────────────────────────
        pw.Center(
          child: pw.Text(
            'Gerado em: ${DateTime.now().toLocal().toString().split('.')[0]}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ),
      ],
    );
  }
}
