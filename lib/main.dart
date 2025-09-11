import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'servicos/firebase_lembrete_service.dart';

// TELAS
import 'telas/carregamento_tela.dart';
import 'telas/login_tela.dart';
import 'telas/recuperacao_senha_tela.dart';
import 'telas/cadastro_tela.dart';
import 'telas/perfil_tela.dart';

// Menus
import 'telas/menu_aluno_tela.dart';
import 'telas/menu_personal_tela.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await FirebaseLembreteService.init();
  }

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
        '/perfil': (context) => const PerfilTela(),
        '/menu-aluno': (context) => const MenuAlunoTela(),
        '/menu-personal': (context) => const MenuPersonalTela(),
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

          final uid = snap.data!.uid;
          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance.collection('users').doc(uid).get(),
            builder: (context, snapUser) {
              if (snapUser.connectionState == ConnectionState.waiting) {
                return const CarregamentoTela();
              }
              if (!snapUser.hasData || !snapUser.data!.exists) {
                return const LoginTela();
              }

              final dados = snapUser.data!.data() as Map<String, dynamic>;
              final tipo = (dados['tipo'] ?? 'aluno').toString().toLowerCase();

              if (tipo == 'personal') {
                return const MenuPersonalTela();
              } else {
                return const MenuAlunoTela();
              }
            },
          );
        },
      ),
    );
  }
}
