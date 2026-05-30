import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'database/supabase_config.dart';
import 'controllers/veiculo_controller.dart';
import 'controllers/abastecimento_controller.dart';
import 'telas/tela_dashboard.dart';
import 'telas/tela_historico.dart';
import 'telas/tela_veiculos.dart';
import 'telas/tela_cadastro_abastecimento.dart';
import 'telas/auth_wrapper.dart';
import 'telas/tela_perfil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VeiculoController()),
        ChangeNotifierProvider(create: (_) => AbastecimentoController()),
      ],
      child: const CombustivelApp(),
    ),
  );
}

class CombustivelApp extends StatelessWidget {
  const CombustivelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Combustível App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  int _abaSelecionada = 0;

  Future<void> _abrirCadastroAbastecimento() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TelaCadastroAbastecimento()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_gas_station, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Combustível App',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        actions: [
          if (_abaSelecionada == 1)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              tooltip: 'Novo abastecimento',
              onPressed: _abrirCadastroAbastecimento,
            ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            tooltip: 'Meu Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TelaPerfil()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _abaSelecionada,
        children: const [
          TelaDashboard(),
          TelaHistorico(),
          TelaVeiculos(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _abaSelecionada,
        onTap: (i) => setState(() => _abaSelecionada = i),
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            activeIcon: Icon(Icons.directions_car),
            label: 'Veículos',
          ),
        ],
      ),
      floatingActionButton: _abaSelecionada != 2
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF1565C0),
              onPressed: _abrirCadastroAbastecimento,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Abastecer',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }
}