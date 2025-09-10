import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart'; // Configurações do FlutterFire
import 'servicos/firebase_lembrete_service.dart';

// TELAS
import 'telas/carregamento_tela.dart';
import 'telas/login_tela.dart';
import 'telas/recuperacao_senha_tela.dart';
import 'telas/cadastro_tela.dart';
import 'telas/perfil_tela.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa lembretes locais só no mobile
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
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const CarregamentoTela();
          }
          if (!snap.hasData) {
            // Sempre começa pelo Login
            return const LoginTela();
          }
          // Usuário logado → vai para perfil
          return const PerfilTela();
        },
      ),
    );
  }
}
