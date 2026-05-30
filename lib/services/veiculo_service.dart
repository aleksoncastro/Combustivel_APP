import 'package:supabase_flutter/supabase_flutter.dart';
import '../modelos/veiculo.dart';

class VeiculoService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<int> inserirVeiculo(Veiculo v) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) throw Exception('Usuário não autenticado');

    final map = v.toMap();
    if (v.id == null) {
      map.remove('id');
    }
    map['user_id'] = currentUser.id;

    final response = await _client.from('veiculo').insert(map).select('id').single();
    final novoId = response['id'] as int;
    v.id = novoId;
    return novoId;
  }

  Future<List<Veiculo>> listarVeiculos() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return [];

    final response = await _client.from('veiculo').select().eq('user_id', currentUser.id);
    final List list = response;
    return list
        .map((m) => Veiculo.fromMap(Map<String, dynamic>.from(m)))
        .toList()
      ..sort((a, b) => a.nome.compareTo(b.nome));
  }

  Future<void> deletarVeiculo(int id) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) throw Exception('Usuário não autenticado');

    await _client.from('veiculo').delete().eq('id', id).eq('user_id', currentUser.id);
  }
}
