import 'package:flutter/material.dart';
import '../modelos/abastecimento.dart';
import '../widgets/header_widget.dart';
import '../widgets/texto_formatado_widget.dart';

class TelaDetalheAbastecimento extends StatelessWidget {
  final Abastecimento abastecimento;

  const TelaDetalheAbastecimento({
    super.key,
    required this.abastecimento,
  });

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
    return Scaffold(
      appBar: const HeaderWidget(title: 'Detalhes do Abastecimento'),
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
                    texto: abastecimento.tipoCombustivel,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  TextoFormatado(
                    texto:
                        'R\$ ${abastecimento.valorTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextoFormatado(
                    texto: abastecimento.data,
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
                  _linha('Veículo', abastecimento.nomeVeiculo,
                      Icons.directions_car, const Color(0xFF1565C0)),
                  const Divider(),
                  _linha('Posto', abastecimento.posto,
                      Icons.store, Colors.orange),
                  const Divider(),
                  _linha('Litros abastecidos',
                      '${abastecimento.litros.toStringAsFixed(3)} L',
                      Icons.water_drop, Colors.teal),
                  const Divider(),
                  _linha('Valor por litro',
                      'R\$ ${abastecimento.valorPorLitro.toStringAsFixed(3)}',
                      Icons.monetization_on, Colors.green),
                  const Divider(),
                  _linha('Quilometragem atual',
                      '${abastecimento.kmAtual.toStringAsFixed(0)} km',
                      Icons.speed, Colors.purple),
                  if (abastecimento.kmAnterior != null) ...[
                    const Divider(),
                    _linha('Km anterior',
                        '${abastecimento.kmAnterior!.toStringAsFixed(0)} km',
                        Icons.history, Colors.grey),
                  ],
                  if (abastecimento.mediaConsumo != null) ...[
                    const Divider(),
                    _linha('Média de consumo',
                        '${abastecimento.mediaConsumo!.toStringAsFixed(2)} km/L',
                        Icons.eco, Colors.green),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
