import 'package:flutter/material.dart';
import '../modelos/abastecimento.dart';
import '../services/abastecimento_service.dart';

class AbastecimentoController extends ChangeNotifier {
  final AbastecimentoService _service = AbastecimentoService();

  List<Abastecimento> _abastecimentos = [];
  List<Abastecimento> get abastecimentos => _abastecimentos;

  Map<String, double> _resumoMes = {};
  Map<String, double> get resumoMesData => _resumoMes;

  bool _carregando = false;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  Future<void> carregarAbastecimentos() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _abastecimentos = await _service.listarAbastecimentos();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> carregarResumoMes(String mesAno) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _resumoMes = await _service.resumoMes(mesAno);
    } catch (e) {
      _erro = e.toString();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> carregarDashboard(String mesAno) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      // Carrega ambos em paralelo para otimizar
      final resultados = await Future.wait([
        _service.listarAbastecimentos(),
        _service.resumoMes(mesAno),
      ]);
      _abastecimentos = resultados[0] as List<Abastecimento>;
      _resumoMes = resultados[1] as Map<String, double>;
    } catch (e) {
      _erro = e.toString();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<int> inserirAbastecimento(Abastecimento a, {String? mesAnoFiltro}) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final novoId = await _service.inserirAbastecimento(a);
      if (mesAnoFiltro != null) {
        await carregarDashboard(mesAnoFiltro);
      } else {
        await carregarAbastecimentos();
      }
      return novoId;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletarAbastecimento(int id, {String? mesAnoFiltro}) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      await _service.deletarAbastecimento(id);
      if (mesAnoFiltro != null) {
        await carregarDashboard(mesAnoFiltro);
      } else {
        await carregarAbastecimentos();
      }
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
