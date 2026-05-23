import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/veiculo.dart';
import '../modelos/abastecimento.dart';

class SupabaseRepository {
  static final SupabaseRepository instancia = SupabaseRepository._interno();
  SupabaseRepository._interno();

  final SupabaseClient _client = Supabase.instance.client;

  // ─── VEÍCULOS ────────────────────────────────────────────
  Future<int> inserirVeiculo(Veiculo v) async {
    final map = v.toMap();
    if (v.id == null) {
      map.remove('id');
    }
    final response = await _client.from('veiculo').insert(map).select('id').single();
    final novoId = response['id'] as int;
    v.id = novoId;
    return novoId;
  }

  Future<List<Veiculo>> listarVeiculos() async {
    final response = await _client.from('veiculo').select();
    final List list = response;
    return list
        .map((m) => Veiculo.fromMap(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
  }

  Future<void> deletarVeiculo(int id) async {
    await _client.from('veiculo').delete().eq('id', id);
  }

  // ─── ABASTECIMENTOS ──────────────────────────────────────
  Future<int> inserirAbastecimento(Abastecimento a) async {
    final map = a.toMap();
    if (a.id == null) {
      map.remove('id');
    }
    final response = await _client.from('abastecimento').insert(map).select('id').single();
    final novoId = response['id'] as int;
    a.id = novoId;
    return novoId;
  }

  Future<List<Abastecimento>> listarAbastecimentos() async {
    final response = await _client.from('abastecimento').select();
    final List list = response;
    return list
        .map((m) => Abastecimento.fromMap(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  Future<List<Abastecimento>> listarAbastecimentosPorVeiculo(int veiculoId) async {
    final response = await _client.from('abastecimento').select().eq('veiculoId', veiculoId);
    final List list = response;
    return list
        .map((m) => Abastecimento.fromMap(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  Future<void> deletarAbastecimento(int id) async {
    await _client.from('abastecimento').delete().eq('id', id);
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
