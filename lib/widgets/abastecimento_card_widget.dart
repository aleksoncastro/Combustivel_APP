import 'package:flutter/material.dart';
import '../modelos/abastecimento.dart';

class AbastecimentoCardWidget extends StatelessWidget {
  final Abastecimento abastecimento;
  final VoidCallback? onDeletar;
  final VoidCallback? onTap;

  const AbastecimentoCardWidget({
    super.key,
    required this.abastecimento,
    this.onDeletar,
    this.onTap,
  });

  Color get _corCombustivel {
    switch (abastecimento.tipoCombustivel) {
      case 'Gasolina': return Colors.orange;
      case 'Etanol':   return Colors.green;
      case 'Diesel':   return Colors.blueGrey;
      case 'GNV':      return Colors.purple;
      default:         return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cor = _corCombustivel;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cor.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ícone combustível
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.local_gas_station, color: cor, size: 24),
            ),
            const SizedBox(width: 10),
            // Informações principais
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: cor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          abastecimento.tipoCombustivel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: cor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          abastecimento.nomeVeiculo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    abastecimento.posto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 8,
                    children: [
                      Text(
                        '${abastecimento.litros.toStringAsFixed(2)}L',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      Text(
                        '${abastecimento.kmAtual.toStringAsFixed(0)} km',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                      if (abastecimento.mediaConsumo != null)
                        Text(
                          '${abastecimento.mediaConsumo!.toStringAsFixed(1)} km/L',
                          style: TextStyle(fontSize: 11, color: Colors.green.shade600),
                        ),
                    ],
                  ),
                  Text(
                    abastecimento.data,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Valor e deletar
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'R\$ ${abastecimento.valorTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ),
                if (onDeletar != null)
                  GestureDetector(
                    onTap: onDeletar,
                    child: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}