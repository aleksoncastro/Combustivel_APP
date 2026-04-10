import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/veiculo.dart';
import '../modelos/abastecimento.dart';

class DatabaseHelper {
  static final DatabaseHelper instancia = DatabaseHelper._interno();
  DatabaseHelper._interno();

  static const _keyVeiculos = 'veiculos';
  static const _keyAbastecimentos = 'abastecimentos';

  // ─── VEÍCULOS ────────────────────────────────────────────
  Future<int> inserirVeiculo(Veiculo v) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await listarVeiculos();
    final novoId = DateTime.now().millisecondsSinceEpoch;
    v.id = novoId;
    lista.add(v);
    await prefs.setString(
      _keyVeiculos,
      jsonEncode(lista.map((e) => e.toMap()).toList()),
    );
    return novoId;
  }

  Future<List<Veiculo>> listarVeiculos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyVeiculos);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded
        .map((m) => Veiculo.fromMap(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
  }

  Future<void> deletarVeiculo(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final veiculos = await listarVeiculos();
    veiculos.removeWhere((v) => v.id == id);
    await prefs.setString(
      _keyVeiculos,
      jsonEncode(veiculos.map((e) => e.toMap()).toList()),
    );
    final abast = await listarAbastecimentos();
    abast.removeWhere((a) => a.veiculoId == id);
    await prefs.setString(
      _keyAbastecimentos,
      jsonEncode(abast.map((e) => e.toMap()).toList()),
    );
  }

  // ─── ABASTECIMENTOS ──────────────────────────────────────
  Future<int> inserirAbastecimento(Abastecimento a) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await listarAbastecimentos();
    final novoId = DateTime.now().millisecondsSinceEpoch;
    a.id = novoId;
    lista.add(a);
    await prefs.setString(
      _keyAbastecimentos,
      jsonEncode(lista.map((e) => e.toMap()).toList()),
    );
    return novoId;
  }

  Future<List<Abastecimento>> listarAbastecimentos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAbastecimentos);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded
        .map((m) => Abastecimento.fromMap(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  Future<List<Abastecimento>> listarAbastecimentosPorVeiculo(int veiculoId) async {
    final lista = await listarAbastecimentos();
    return lista.where((a) => a.veiculoId == veiculoId).toList();
  }

  Future<void> deletarAbastecimento(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await listarAbastecimentos();
    lista.removeWhere((a) => a.id == id);
    await prefs.setString(
      _keyAbastecimentos,
      jsonEncode(lista.map((e) => e.toMap()).toList()),
    );
  }

  // ─── RESUMO DO MÊS ───────────────────────────────────────
  Future<Map<String, double>> resumoMes(String mesAno) async {
    final lista = await listarAbastecimentos();
    final doMes = lista.where((a) => a.data.startsWith(mesAno)).toList();
    double totalGasto = 0;
    double totalLitros = 0;
    double totalKm = 0;
    int countMedia = 0;

    for (final a in doMes) {
      totalGasto += a.valorTotal;
      totalLitros += a.litros;
      if (a.mediaConsumo != null) {
        totalKm += a.mediaConsumo!;
        countMedia++;
      }
    }

    return {
      'totalGasto': totalGasto,
      'totalLitros': totalLitros,
      'mediaConsumo': countMedia > 0 ? totalKm / countMedia : 0,
      'qtdAbastecimentos': doMes.length.toDouble(),
    };
  }
}