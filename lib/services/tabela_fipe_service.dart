import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_client.dart';

class TabelaFipeService {
  final ApiClient _apiClient = ApiClient();

  /// Busca as marcas de veículos baseadas no tipo (ex: carros, motos, caminhoes)
  /// Consumindo a API pública da BrasilAPI
  Future<List<String>> buscarMarcas(String tipoVeiculo) async {
    try {
      final url = Uri.parse('https://brasilapi.com.br/api/fipe/marcas/v1/$tipoVeiculo');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List dados = jsonDecode(response.body);
        return dados.map((e) => e['nome'].toString()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Exemplo de uso do ApiClient para sincronização (comentado se não for usado)
  Future<bool> sincronizarAbastecimento(Map<String, dynamic> dados) async {
    try {
      final response = await _apiClient.post('/abastecimentos/sync', body: dados);
      return response != null && response['sucesso'] == true;
    } catch (e) {
      return false;
    }
  }
}
