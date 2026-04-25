import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../modelos/abastecimento.dart';
import '../widgets/carrossel_destaques_widget.dart';
import '../widgets/resumo_card_widget.dart';
import '../widgets/abastecimento_card_widget.dart';
import '../widgets/texto_formatado_widget.dart';

class TelaDashboard extends StatefulWidget {
  const TelaDashboard({super.key});

  @override
  State<TelaDashboard> createState() => _TelaDashboardState();
}

class _TelaDashboardState extends State<TelaDashboard> {
  final _db = DatabaseHelper.instancia;
  Map<String, double> _resumo = {};
  List<Abastecimento> _recentes = [];
  bool _carregando = true;

  String get _mesAtual {
    final now = DateTime.now();
    return '${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String get _mesAnoParam {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    final resumo = await _db.resumoMes(_mesAnoParam);
    final todos = await _db.listarAbastecimentos();
    setState(() {
      _resumo = resumo;
      _recentes = todos.take(3).toList();
      _carregando = false;
    });
  }

  List<DestaqueItem> get _destaques {
    final gasto = _resumo['totalGasto'] ?? 0;
    final litros = _resumo['totalLitros'] ?? 0;
    final media = _resumo['mediaConsumo'] ?? 0;
    final qtd = _resumo['qtdAbastecimentos'] ?? 0;

    return [
      DestaqueItem(
        icone: Icons.attach_money,
        titulo: 'Total gasto no mês ($_mesAtual)',
        descricao: 'R\$ ${gasto.toStringAsFixed(2)}',
        cor: const Color(0xFF1565C0),
      ),
      DestaqueItem(
        icone: Icons.water_drop,
        titulo: 'Litros abastecidos no mês',
        descricao: '${litros.toStringAsFixed(2)} L',
        cor: Colors.teal,
      ),
      DestaqueItem(
        icone: Icons.speed,
        titulo: 'Média de consumo do mês',
        descricao: media > 0 ? '${media.toStringAsFixed(1)} km/L' : '--',
        cor: Colors.orange,
      ),
      DestaqueItem(
        icone: Icons.local_gas_station,
        titulo: 'Abastecimentos no mês',
        descricao: '${qtd.toInt()} vezes',
        cor: Colors.purple,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho do dashboard
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1565C0),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TextoFormatado(
                          texto: 'Resumo do Mês',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextoFormatado(
                          texto: _mesAtual,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Grid de cards de resumo
                        Row(
                          children: [
                            Expanded(
                              child: ResumoCardWidget(
                                titulo: 'Total Gasto',
                                valor:
                                    'R\$ ${(_resumo['totalGasto'] ?? 0).toStringAsFixed(2)}',
                                icone: Icons.attach_money,
                                cor: const Color(0xFF1565C0),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ResumoCardWidget(
                                titulo: 'Litros',
                                valor:
                                    '${(_resumo['totalLitros'] ?? 0).toStringAsFixed(2)} L',
                                icone: Icons.water_drop,
                                cor: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ResumoCardWidget(
                                titulo: 'Média km/L',
                                valor: (_resumo['mediaConsumo'] ?? 0) > 0
                                    ? '${(_resumo['mediaConsumo']!).toStringAsFixed(1)} km/L'
                                    : '--',
                                icone: Icons.speed,
                                cor: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ResumoCardWidget(
                                titulo: 'Abastecimentos',
                                valor:
                                    '${(_resumo['qtdAbastecimentos'] ?? 0).toInt()}x',
                                icone: Icons.local_gas_station,
                                cor: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Carrossel de destaques (PageView.builder)
                  const Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 10),
                    child: TextoFormatado(
                      texto: '⭐ Destaques',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  CarrosselDestaquesWidget(itens: _destaques),

                  const SizedBox(height: 20),

                  // Últimos abastecimentos
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        TextoFormatado(
                          texto: '⛽ Últimos Abastecimentos',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_recentes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: TextoFormatado(
                          texto: 'Nenhum abastecimento registrado ainda.',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 14),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentes.length,
                      itemBuilder: (context, i) {
                        return AbastecimentoCardWidget(
                          abastecimento: _recentes[i],
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
