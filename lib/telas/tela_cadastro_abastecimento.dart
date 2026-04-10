import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../modelos/abastecimento.dart';
import '../modelos/veiculo.dart';
import '../widgets/header_widget.dart';
import '../widgets/texto_formatado_widget.dart';

class TelaCadastroAbastecimento extends StatefulWidget {
  const TelaCadastroAbastecimento({super.key});

  @override
  State<TelaCadastroAbastecimento> createState() =>
      _TelaCadastroAbastecimentoState();
}

class _TelaCadastroAbastecimentoState
    extends State<TelaCadastroAbastecimento> {
  final _db = DatabaseHelper.instancia;

  final _postoController = TextEditingController();
  final _litrosController = TextEditingController();
  final _valorPorLitroController = TextEditingController();
  final _kmAtualController = TextEditingController();
  final _kmAnteriorController = TextEditingController();

  List<Veiculo> _veiculos = [];
  Veiculo? _veiculoSelecionado;
  String _tipoCombustivel = 'Gasolina';
  bool _salvando = false;

  final List<String> _tiposCombustivel = ['Gasolina', 'Etanol', 'Diesel', 'GNV'];

  double get _valorTotal {
    final l = double.tryParse(
            _litrosController.text.replaceAll(',', '.')) ??
        0;
    final v = double.tryParse(
            _valorPorLitroController.text.replaceAll(',', '.')) ??
        0;
    return l * v;
  }

  @override
  void initState() {
    super.initState();
    _carregarVeiculos();
    _litrosController.addListener(() => setState(() {}));
    _valorPorLitroController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _postoController.dispose();
    _litrosController.dispose();
    _valorPorLitroController.dispose();
    _kmAtualController.dispose();
    _kmAnteriorController.dispose();
    super.dispose();
  }

  Future<void> _carregarVeiculos() async {
    final lista = await _db.listarVeiculos();
    setState(() => _veiculos = lista);
  }

  String _dataAtual() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String _dataAtualIso() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _salvar() async {
    if (_veiculoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecione um veículo!'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_postoController.text.trim().isEmpty ||
        _litrosController.text.trim().isEmpty ||
        _valorPorLitroController.text.trim().isEmpty ||
        _kmAtualController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos obrigatórios!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    final a = Abastecimento(
      veiculoId: _veiculoSelecionado!.id!,
      nomeVeiculo: _veiculoSelecionado!.nome,
      posto: _postoController.text.trim(),
      tipoCombustivel: _tipoCombustivel,
      litros: double.parse(_litrosController.text.replaceAll(',', '.')),
      valorPorLitro:
          double.parse(_valorPorLitroController.text.replaceAll(',', '.')),
      kmAtual:
          double.parse(_kmAtualController.text.replaceAll(',', '.')),
      kmAnterior: _kmAnteriorController.text.trim().isNotEmpty
          ? double.tryParse(
              _kmAnteriorController.text.replaceAll(',', '.'))
          : null,
      data: _dataAtualIso(),
    );

    await _db.inserirAbastecimento(a);
    setState(() => _salvando = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Abastecimento salvo com sucesso!'),
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
          borderSide:
              const BorderSide(color: Color(0xFF1565C0), width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderWidget(title: 'Novo Abastecimento'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seleção de veículo
            const TextoFormatado(
              texto: 'Veículo *',
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (_veiculos.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade600),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: TextoFormatado(
                        texto:
                            'Nenhum veículo cadastrado. Vá até a aba Veículos para adicionar.',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<Veiculo>(
                value: _veiculoSelecionado,
                decoration: _deco('Selecione o veículo', Icons.directions_car),
                items: _veiculos
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text('${v.nome} (${v.placa})'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _veiculoSelecionado = v),
              ),

            const SizedBox(height: 16),

            // Tipo de combustível
            const TextoFormatado(
              texto: 'Tipo de Combustível *',
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _tiposCombustivel.map((tipo) {
                final sel = tipo == _tipoCombustivel;
                return ChoiceChip(
                  label: Text(tipo),
                  selected: sel,
                  selectedColor: const Color(0xFF1565C0),
                  labelStyle: TextStyle(
                    color: sel ? Colors.white : Colors.black87,
                    fontWeight:
                        sel ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) =>
                      setState(() => _tipoCombustivel = tipo),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _postoController,
              decoration: _deco('Nome do Posto *', Icons.store),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _litrosController,
                    decoration: _deco('Litros *', Icons.water_drop),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _valorPorLitroController,
                    decoration:
                        _deco('R\$/Litro *', Icons.monetization_on),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                  ),
                ),
              ],
            ),

            // Preview do valor total
            if (_valorTotal > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calculate, color: Colors.green.shade600),
                      const SizedBox(width: 10),
                      TextoFormatado(
                        texto:
                            'Valor total: R\$ ${_valorTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kmAtualController,
                    decoration: _deco('KM Atual *', Icons.speed),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _kmAnteriorController,
                    decoration:
                        _deco('KM Anterior (opcional)', Icons.history),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: TextoFormatado(
                texto: 'Data: ${_dataAtual()} (automática)',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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
                    : const Icon(Icons.save),
                label: const Text('Salvar Abastecimento',
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
