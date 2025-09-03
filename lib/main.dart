import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart'; // Configurações geradas pelo FlutterFire
import 'servicos/firebase_lembrete_service.dart'; // Inicialização de lembretes locais

// TELAS
import 'telas/carregamento_tela.dart';
import 'telas/login_tela.dart';
import 'telas/recuperacao_senha_tela.dart';
import 'telas/cadastro_tela.dart';
import 'telas/menu_aluno_tela.dart';
import 'telas/menu_personal_tela.dart';
import 'telas/treino_aluno_tela.dart';
import 'telas/treino_personal_tela.dart';
import 'telas/dieta_aluno_tela.dart';
import 'telas/dieta_personal_tela.dart';
import 'telas/progresso_tela.dart';
import 'telas/perfil_aluno_tela.dart';
import 'telas/perfil_personal_tela.dart';
import 'telas/placeholder_telas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa lembretes locais
  await FirebaseLembreteService.init();

  runApp(const MeuAplicativo());
}

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShapeUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.amber,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.amber),
        ),
      ),
      routes: {
        '/login': (context) => const LoginTela(),
        '/recuperacao': (context) => const RecuperacaoSenhaTela(),
        '/cadastro': (context) => const CadastroTela(),
        '/menu-aluno': (context) => const MenuAlunoTela(),
        '/menu-personal': (context) => const MenuPersonalTela(),
        '/treino-aluno': (context) => const TreinoAlunoTela(),
        '/treino-personal': (context) => const TreinoPersonalTela(),
        '/dieta-aluno': (context) => const DietaAlunoTela(),
        '/dieta-personal': (context) => const DietaPersonalTela(),
        '/progresso': (context) => const ProgressoTela(),
        '/perfil-aluno': (context) => const PerfilAlunoTela(),
        '/perfil-personal': (context) => const PerfilPersonalTela(),

        // Essas telas vêm do placeholder_telas.dart
        '/alunos': (context) => const AlunosTela(),
        '/criar-treino': (context) => const CriarTreinoTela(),
        '/criar-dieta': (context) => const CriarDietaTela(),
        '/evolucao-aluno': (context) => const EvolucaoAlunoTela(),
        '/lembretes': (context) => const LembretesTela(),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const CarregamentoTela();
          }
          if (!snap.hasData) {
            return const LoginTela();
          }

          final user = snap.data!;
          final nome = (user.displayName ?? '').toLowerCase();
          final ehTreinador =
              nome.contains('treinador') || nome.contains('personal');

          return ehTreinador ? const MenuPersonalTela() : const MenuAlunoTela();
        },
      ),
    );
  }
}
