import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Retorna o usuário atual logado, ou nulo se não estiver logado.
  User? get usuarioAtual => _client.auth.currentUser;

  /// Stream para escutar mudanças no estado de autenticação (login/logout).
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Faz o login com e-mail e senha.
  Future<AuthResponse> login(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Cria uma nova conta com e-mail e senha.
  Future<AuthResponse> cadastrar(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// Desloga o usuário atual.
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
