import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection('users').doc(uid);

  Future<void> ensureProfileDoc() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final ref = _userRef(uid);
    final snap = await ref.get();
    final user = _auth.currentUser!;
    if (!snap.exists) {
      await ref.set({
        'displayName': user.displayName ?? '',
        'email': user.email,
        'photoURL': user.photoURL,
        'role': null, // "aluno" | "treinador" (defina depois)
        'sexo': null,
        'idade': null,
        'altura': null,
        'peso': null,
        'idioma': 'pt-BR',
        'cref': null, // só se for treinador
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _userRef(uid).get();
    return doc.data();
  }

  Future<void> updateMyProfile({
    String? displayName,
    String? sexo,
    int? idade,
    double? altura,
    double? peso,
    String? idioma,
    String? cref,
    String? role,
    String? photoURL,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final data = <String, dynamic>{
      if (displayName != null) 'displayName': displayName,
      if (sexo != null) 'sexo': sexo,
      if (idade != null) 'idade': idade,
      if (altura != null) 'altura': altura,
      if (peso != null) 'peso': peso,
      if (idioma != null) 'idioma': idioma,
      if (cref != null) 'cref': cref,
      if (role != null) 'role': role, // "aluno" | "treinador"
      if (photoURL != null) 'photoURL': photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _userRef(uid).update(data);
  }
}
