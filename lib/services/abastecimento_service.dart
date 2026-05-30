import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/abastecimento.dart';

class AbastecimentoService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<int> inserirAbastecimento(Abastecimento a) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) throw Exception('Usuário não autenticado');

    final map = a.toMap();
    if (a.id == null) {
      map.remove('id');
    }
    map['user_id'] = currentUser.id;

    final response = await _client.from('abastecimento').insert(map).select('id').single();
    final novoId = response['id'] as int;
    a.id = novoId;
    return novoId;
  }

  Future<List<Abastecimento>> listarAbastecimentos() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return [];

    final response = await _client.from('abastecimento').select().eq('user_id', currentUser.id);
    final List list = response;
    return list
        .map((m) => Abastecimento.fromMap(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  Future<List<Abastecimento>> listarAbastecimentosPorVeiculo(int veiculoId) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return [];

    final response = await _client.from('abastecimento').select().eq('veiculoId', veiculoId).eq('user_id', currentUser.id);
    final List list = response;
    return list
        .map((m) => Abastecimento.fromMap(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  Future<void> deletarAbastecimento(int id) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) throw Exception('Usuário não autenticado');

    await _client.from('abastecimento').delete().eq('id', id).eq('user_id', currentUser.id);
  }

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
