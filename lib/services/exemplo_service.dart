import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class TabelaFipeService {
  final ApiClient _apiClient = ApiClient();

  // Exemplo consumindo a API pública da BrasilAPI (Marcas de veículos)
  Future<List<String>> buscarMarcas(String tipoVeiculo) async {
    try {
      // Fazendo a chamada direta com o pacote http para testes
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

  // Se você fosse fazer um POST para o seu back-end externo
  Future<bool> sincronizarAbastecimento(Map<String, dynamic> dados) async {
    try {
      final response = await _apiClient.post('/abastecimentos/sync', body: dados);
      return response != null && response['sucesso'] == true;
    } catch (e) {
      print('Erro ao sincronizar abastecimento: $e');
      return false;
    }
  }
}
