import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/header_widget.dart';
import '../widgets/texto_formatado_widget.dart';

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final usuario = authService.usuarioAtual;

    return Scaffold(
      appBar: const HeaderWidget(title: 'Meu Perfil'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF1565C0),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            TextoFormatado(
              texto: 'Conectado como:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            TextoFormatado(
              texto: usuario?.email ?? 'Usuário não identificado',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                await authService.logout();
                if (context.mounted) {
                  Navigator.pop(context); // Fecha a tela de perfil
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Sair da Conta',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
