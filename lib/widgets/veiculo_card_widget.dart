import 'package:flutter/material.dart';
import '../modelos/veiculo.dart';
import 'texto_formatado_widget.dart';

class VeiculoCardWidget extends StatelessWidget {
  final Veiculo veiculo;
  final VoidCallback? onDeletar;
  final VoidCallback? onTap;

  const VeiculoCardWidget({
    super.key,
    required this.veiculo,
    this.onDeletar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.directions_car,
                  color: Color(0xFF1565C0), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextoFormatado(
                    texto: veiculo.nome,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  TextoFormatado(
                    texto: '${veiculo.modelo} • ${veiculo.ano}',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.pin, size: 13, color: Colors.grey.shade500),
                      const SizedBox(width: 2),
                      TextoFormatado(
                        texto: veiculo.placa.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onDeletar != null)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                onPressed: onDeletar,
              ),
          ],
        ),
      ),
    );
  }
}
