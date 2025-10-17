import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/progresso.dart';

class FirebaseProgressoService {
  final CollectionReference progressoRef =
  FirebaseFirestore.instance.collection('progresso');

  // Adicionar novo registro de progresso
  Future<void> adicionarProgresso(Progresso progresso) async {
    final dados = progresso.toMap();

    // 🔹 Garante que todos os campos de medidas estejam presentes
    final medidasPadrao = {
      'bracoDireito': (dados['medidas']['bracoDireito'] ?? 0.0).toDouble(),
      'bracoEsquerdo': (dados['medidas']['bracoEsquerdo'] ?? 0.0).toDouble(),
      'coxaDireita': (dados['medidas']['coxaDireita'] ?? 0.0).toDouble(),
      'coxaEsquerda': (dados['medidas']['coxaEsquerda'] ?? 0.0).toDouble(),
      'cintura': (dados['medidas']['cintura'] ?? 0.0).toDouble(),
      'quadril': (dados['medidas']['quadril'] ?? 0.0).toDouble(),
    };

    dados['medidas'] = medidasPadrao;

    await progressoRef.doc(progresso.id).set(dados);
  }

  // Buscar progresso por ID
  Future<Progresso?> buscarProgressoPorId(String id) async {
    final doc = await progressoRef.doc(id).get();
    if (doc.exists) {
      return Progresso.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // Listar todos os registros de um aluno
  Future<List<Progresso>> listarProgressoPorAluno(String alunoId) async {
    final snapshot = await progressoRef
        .where('alunoId', isEqualTo: alunoId)
        .orderBy('data', descending: false)
        .get();

    return snapshot.docs
        .map((doc) =>
        Progresso.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // Atualizar registro
  Future<void> atualizarProgresso(Progresso progresso) async {
    final dados = progresso.toMap();

    // 🔹 Garante que todos os campos existam no update
    final medidasPadrao = {
      'bracoDireito': (dados['medidas']['bracoDireito'] ?? 0.0).toDouble(),
      'bracoEsquerdo': (dados['medidas']['bracoEsquerdo'] ?? 0.0).toDouble(),
      'coxaDireita': (dados['medidas']['coxaDireita'] ?? 0.0).toDouble(),
      'coxaEsquerda': (dados['medidas']['coxaEsquerda'] ?? 0.0).toDouble(),
      'cintura': (dados['medidas']['cintura'] ?? 0.0).toDouble(),
      'quadril': (dados['medidas']['quadril'] ?? 0.0).toDouble(),
    };

    dados['medidas'] = medidasPadrao;
    dados['atualizadoEm'] = DateTime.now().toIso8601String();

    await progressoRef.doc(progresso.id).update(dados);
  }

  // Deletar registro
  Future<void> deletarProgresso(String id) async {
    await progressoRef.doc(id).delete();
  }
}
