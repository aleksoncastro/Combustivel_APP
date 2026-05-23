import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException: [$statusCode] $message';
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // URL base para facilitar as chamadas (exemplo genérico)
  static const String baseUrl = 'https://sua-api.com/api';

  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Adiciona o Token JWT para autenticação, se necessário.
  void setAuthToken(String token) {
    _defaultHeaders['Authorization'] = 'Bearer $token';
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    return _request(() => http.get(
          Uri.parse('$baseUrl$endpoint'),
          headers: {..._defaultHeaders, if (headers != null) ...headers},
        ));
  }

  Future<dynamic> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    return _request(() => http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: {..._defaultHeaders, if (headers != null) ...headers},
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> put(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    return _request(() => http.put(
          Uri.parse('$baseUrl$endpoint'),
          headers: {..._defaultHeaders, if (headers != null) ...headers},
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    return _request(() => http.delete(
          Uri.parse('$baseUrl$endpoint'),
          headers: {..._defaultHeaders, if (headers != null) ...headers},
        ));
  }

  /// Wrapper interno que processa a requisição e lida com erros de forma global
  Future<dynamic> _request(Future<http.Response> Function() requestFunc) async {
    try {
      final response = await requestFunc().timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      // Aqui você poderia registrar num serviço de crashlytics, por exemplo
      throw Exception('Falha na comunicação com o servidor: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return response.body; // Retorna como string se não for JSON
      }
    } else {
      String errorMessage = 'Erro desconhecido';
      try {
        final errorBody = jsonDecode(response.body);
        errorMessage = errorBody['message'] ?? errorBody['error'] ?? response.body;
      } catch (e) {
        errorMessage = response.body;
      }
      throw ApiException(response.statusCode, errorMessage);
    }
  }
}
