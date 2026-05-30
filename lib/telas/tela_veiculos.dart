import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/veiculo_controller.dart';
import '../modelos/veiculo.dart';
import '../widgets/veiculo_card_widget.dart';
import '../widgets/texto_formatado_widget.dart';
import 'tela_cadastro_veiculo.dart';

class TelaVeiculos extends StatefulWidget {
  const TelaVeiculos({super.key});

  @override
  State<TelaVeiculos> createState() => _TelaVeiculosState();
}

class _TelaVeiculosState extends State<TelaVeiculos> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VeiculoController>().carregarVeiculos();
    });
  }

  Future<void> _deletar(Veiculo v) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir veículo?'),
        content: const Text(
            'Todos os abastecimentos deste veículo também serão removidos.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmar == true && v.id != null) {
      try {
        await context.read<VeiculoController>().deletarVeiculo(v.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veículo removido!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir veículo: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _abrirCadastro() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => const TelaCadastroVeiculo()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VeiculoController>();
    final veiculos = controller.veiculos;
    final carregando = controller.carregando;

    return Stack(
      children: [
        carregando && veiculos.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : veiculos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car,
                            size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        TextoFormatado(
                          texto: 'Nenhum veículo cadastrado ainda.',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 8),
                        TextoFormatado(
                          texto: 'Toque no + para adicionar seu primeiro veículo.',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => controller.carregarVeiculos(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: veiculos.length,
                      itemBuilder: (context, i) => VeiculoCardWidget(
                        veiculo: veiculos[i],
                        onDeletar: () => _deletar(veiculos[i]),
                      ),
                    ),
                  ),
        // FAB
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton.extended(
            heroTag: 'fab_veiculos',
            onPressed: _abrirCadastro,
            backgroundColor: const Color(0xFF1565C0),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Novo Veículo',
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
