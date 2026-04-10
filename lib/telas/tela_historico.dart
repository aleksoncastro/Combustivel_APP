import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../modelos/abastecimento.dart';
import '../widgets/abastecimento_card_widget.dart';
import '../widgets/texto_formatado_widget.dart';
import 'tela_detalhe_abastecimento.dart';

class TelaHistorico extends StatefulWidget {
  const TelaHistorico({super.key});

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  final _db = DatabaseHelper.instancia;
  List<Abastecimento> _todos = [];
  List<Abastecimento> _filtrados = [];
  bool _carregando = true;
  String _filtroCombustivel = 'Todos';

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
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    final lista = await _db.listarAbastecimentos();
    setState(() {
      _todos = lista;
      _aplicarFiltro();
      _carregando = false;
    });
  }

  void _aplicarFiltro() {
    if (_filtroCombustivel == 'Todos') {
      _filtrados = List.from(_todos);
    } else {
      _filtrados = _todos
          .where((a) => a.tipoCombustivel == _filtroCombustivel)
          .toList();
    }
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
    if (confirmar == true && a.id != null) {
      await _db.deletarAbastecimento(a.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abastecimento removido!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _carregarDados();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filtro por combustível
        Container(
          color: const Color(0xFF1565C0).withOpacity(0.05),
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
                      _aplicarFiltro();
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

        // Lista
        Expanded(
          child: _carregando
              ? const Center(child: CircularProgressIndicator())
              : _filtrados.isEmpty
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
                      onRefresh: _carregarDados,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _filtrados.length,
                        itemBuilder: (context, i) {
                          return AbastecimentoCardWidget(
                            abastecimento: _filtrados[i],
                            onDeletar: () => _deletar(_filtrados[i]),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TelaDetalheAbastecimento(
                                    abastecimento: _filtrados[i],
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
