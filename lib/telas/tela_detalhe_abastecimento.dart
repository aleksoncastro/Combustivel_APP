import 'package:flutter/material.dart';
import '../modelos/abastecimento.dart';
import '../services/pdf_service.dart';
import '../widgets/header_widget.dart';
import '../widgets/texto_formatado_widget.dart';

class TelaDetalheAbastecimento extends StatefulWidget {
  final Abastecimento abastecimento;

  const TelaDetalheAbastecimento({
    super.key,
    required this.abastecimento,
  });

  @override
  State<TelaDetalheAbastecimento> createState() =>
      _TelaDetalheAbastecimentoState();
}

class _TelaDetalheAbastecimentoState extends State<TelaDetalheAbastecimento> {
  bool _isExportando = false;

  Future<void> _exportarComprovante() async {
    setState(() => _isExportando = true);
    try {
      final pdfService = PdfService();
      await pdfService.gerarPdfIndividual(widget.abastecimento);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExportando = false);
      }
    }
  }

  Widget _linha(String label, String valor, IconData icone, Color cor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icone, color: cor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextoFormatado(
                  texto: label,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                TextoFormatado(
                  texto: valor,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.abastecimento;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalhes do Abastecimento',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // ── Botão exportar comprovante ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _isExportando
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : Tooltip(
                    message: 'Exportar comprovante PDF',
                    child: IconButton(
                      onPressed: _exportarComprovante,
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Card de valor total em destaque
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.local_gas_station,
                      color: Colors.white70, size: 40),
                  const SizedBox(height: 8),
                  TextoFormatado(
                    texto: a.tipoCombustivel,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  TextoFormatado(
                    texto: 'R\$ ${a.valorTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextoFormatado(
                    texto: a.data,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Detalhes
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _linha('Veículo', a.nomeVeiculo,
                      Icons.directions_car, const Color(0xFF1565C0)),
                  const Divider(),
                  _linha('Posto', a.posto,
                      Icons.store, Colors.orange),
                  const Divider(),
                  _linha('Litros abastecidos',
                      '${a.litros.toStringAsFixed(3)} L',
                      Icons.water_drop, Colors.teal),
                  const Divider(),
                  _linha('Valor por litro',
                      'R\$ ${a.valorPorLitro.toStringAsFixed(3)}',
                      Icons.monetization_on, Colors.green),
                  const Divider(),
                  _linha('Quilometragem atual',
                      '${a.kmAtual.toStringAsFixed(0)} km',
                      Icons.speed, Colors.purple),
                  if (a.kmAnterior != null) ...[
                    const Divider(),
                    _linha('Km anterior',
                        '${a.kmAnterior!.toStringAsFixed(0)} km',
                        Icons.history, Colors.grey),
                  ],
                  if (a.mediaConsumo != null) ...[
                    const Divider(),
                    _linha('Média de consumo',
                        '${a.mediaConsumo!.toStringAsFixed(2)} km/L',
                        Icons.eco, Colors.green),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ── Botão de exportar no corpo também ─────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isExportando ? null : _exportarComprovante,
                icon: _isExportando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf,
                        size: 20, color: Colors.white),
                label: Text(
                  _isExportando ? 'Gerando PDF...' : 'Exportar Comprovante PDF',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
