import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../modelos/veiculo.dart';
import '../widgets/header_widget.dart';
import '../widgets/texto_formatado_widget.dart';

class TelaCadastroVeiculo extends StatefulWidget {
  const TelaCadastroVeiculo({super.key});

  @override
  State<TelaCadastroVeiculo> createState() => _TelaCadastroVeiculoState();
}

class _TelaCadastroVeiculoState extends State<TelaCadastroVeiculo> {
  final _db = DatabaseHelper.instancia;
  final _nomeController = TextEditingController();
  final _modeloController = TextEditingController();
  final _placaController = TextEditingController();
  final _anoController = TextEditingController();
  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _modeloController.dispose();
    _placaController.dispose();
    _anoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_nomeController.text.trim().isEmpty ||
        _modeloController.text.trim().isEmpty ||
        _placaController.text.trim().isEmpty ||
        _anoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos obrigatórios!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _salvando = true);
    final v = Veiculo(
      nome: _nomeController.text.trim(),
      modelo: _modeloController.text.trim(),
      placa: _placaController.text.trim().toUpperCase(),
      ano: _anoController.text.trim(),
    );
    await _db.inserirVeiculo(v);
    setState(() => _salvando = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veículo salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  InputDecoration _deco(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderWidget(title: 'Cadastrar Veículo'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone ilustrativo
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_car,
                    size: 48, color: Color(0xFF1565C0)),
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _nomeController,
              decoration: _deco('Apelido do veículo * (ex: Meu Carro)', Icons.label),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _modeloController,
              decoration: _deco('Modelo * (ex: Fiat Uno)', Icons.directions_car),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _placaController,
                    decoration: _deco('Placa *', Icons.pin),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 8,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _anoController,
                    decoration: _deco('Ano *', Icons.calendar_today),
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),

            // Preview
            if (_nomeController.text.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF1565C0).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.visibility,
                        color: Color(0xFF1565C0), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextoFormatado(
                        texto:
                            '${_nomeController.text} • ${_modeloController.text} • ${_placaController.text.toUpperCase()} • ${_anoController.text}',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF1565C0)),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.directions_car),
                label: const Text('Cadastrar Veículo',
                    style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
