import 'package:flutter/material.dart';
import '../database/database_helper.dart';
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
  final _db = DatabaseHelper.instancia;
  List<Veiculo> _veiculos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarVeiculos();
  }

  Future<void> _carregarVeiculos() async {
    setState(() => _carregando = true);
    final lista = await _db.listarVeiculos();
    setState(() {
      _veiculos = lista;
      _carregando = false;
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
    if (confirmar == true && v.id != null) {
      await _db.deletarVeiculo(v.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veículo removido!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _carregarVeiculos();
    }
  }

  Future<void> _abrirCadastro() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => const TelaCadastroVeiculo()),
    );
    if (resultado == true) _carregarVeiculos();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _carregando
            ? const Center(child: CircularProgressIndicator())
            : _veiculos.isEmpty
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
                    onRefresh: _carregarVeiculos,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: _veiculos.length,
                      itemBuilder: (context, i) => VeiculoCardWidget(
                        veiculo: _veiculos[i],
                        onDeletar: () => _deletar(_veiculos[i]),
                      ),
                    ),
                  ),
        // FAB
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton.extended(
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
