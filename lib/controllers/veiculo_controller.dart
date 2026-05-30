import 'package:flutter/material.dart';
import '../modelos/veiculo.dart';
import '../services/veiculo_service.dart';

class VeiculoController extends ChangeNotifier {
  final VeiculoService _veiculoService = VeiculoService();

  List<Veiculo> _veiculos = [];
  List<Veiculo> get veiculos => _veiculos;

  bool _carregando = false;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  Future<void> carregarVeiculos() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _veiculos = await _veiculoService.listarVeiculos();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<int> inserirVeiculo(Veiculo v) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final novoId = await _veiculoService.inserirVeiculo(v);
      await carregarVeiculos(); // Recarrega a lista após inserção
      return novoId;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletarVeiculo(int id) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      await _veiculoService.deletarVeiculo(id);
      await carregarVeiculos(); // Recarrega a lista após remoção
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
