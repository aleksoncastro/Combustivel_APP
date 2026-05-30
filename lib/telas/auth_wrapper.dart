import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../controllers/veiculo_controller.dart';
import '../controllers/abastecimento_controller.dart';
import '../main.dart';
import 'tela_login.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService();
  String? _ultimoUserId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1565C0)),
            ),
          );
        }

        final session = snapshot.data?.session;

        if (session != null) {
          // O usuário está logado
          final userId = session.user.id;
          
          // Se o usuário mudou (ou acabou de logar), recarrega os dados
          if (_ultimoUserId != userId) {
            _ultimoUserId = userId;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<VeiculoController>().carregarVeiculos();
                context.read<AbastecimentoController>().carregarAbastecimentos();
              }
            });
          }

          return const TelaHome();
        } else {
          // O usuário não está logado
          _ultimoUserId = null;
          return const TelaLogin();
        }
      },
    );
  }
}
