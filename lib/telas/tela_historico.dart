import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/abastecimento_controller.dart';
import '../modelos/abastecimento.dart';
import '../widgets/abastecimento_card_widget.dart';
import '../widgets/texto_formatado_widget.dart';
import '../services/pdf_service.dart';
import 'tela_detalhe_abastecimento.dart';

class TelaHistorico extends StatefulWidget {
  const TelaHistorico({super.key});

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  String _filtroCombustivel = 'Todos';
  bool _isExportando = false;

  final List<String> _combustiveis = [
    'Todos',
    'Gasolina',
    'Etanol',
    'Diesel',
    'GNV'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AbastecimentoController>().carregarAbastecimentos();
    });
  }

  Future<void> _deletar(Abastecimento a) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir abastecimento?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmar == true && a.id != null) {
      try {
        await context.read<AbastecimentoController>().deletarAbastecimento(a.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Abastecimento removido!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _exportarPdf(List<Abastecimento> filtrados) async {
    if (filtrados.isEmpty) return;
    setState(() => _isExportando = true);
    try {
      final pdfService = PdfService();
      await pdfService.gerarECompartilharPdf(filtrados);
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

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AbastecimentoController>();
    final todos = controller.abastecimentos;
    final carregando = controller.carregando;

    final filtrados = _filtroCombustivel == 'Todos'
        ? todos
        : todos.where((a) => a.tipoCombustivel == _filtroCombustivel).toList();

    return Column(
      children: [
        // Filtro por combustível
        Container(
          color: const Color(0xFF1565C0).withValues(alpha: 0.05),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _combustiveis.map((c) {
                final sel = c == _filtroCombustivel;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _filtroCombustivel = c;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFF1565C0)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel
                            ? const Color(0xFF1565C0)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: TextoFormatado(
                      texto: c,
                      style: TextStyle(
                        color: sel ? Colors.white : Colors.grey.shade700,
                        fontSize: 13,
                        fontWeight: sel
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Botão Exportar PDF
        if (filtrados.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 16, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _isExportando ? null : () => _exportarPdf(filtrados),
                  icon: _isExportando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf, size: 18, color: Colors.white),
                  label: const Text(
                    'Exportar PDF',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

        // Lista
        Expanded(
          child: carregando && todos.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : filtrados.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_gas_station,
                              size: 72, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          TextoFormatado(
                            texto: 'Nenhum abastecimento encontrado.',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => controller.carregarAbastecimentos(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: filtrados.length,
                        itemBuilder: (context, i) {
                          return AbastecimentoCardWidget(
                            abastecimento: filtrados[i],
                            onDeletar: () => _deletar(filtrados[i]),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TelaDetalheAbastecimento(
                                    abastecimento: filtrados[i],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
