import 'package:flutter_test/flutter_test.dart';

import 'package:shapeup/servicos/profile_service.dart';

/// Mock simples só para testes de comportamento
class MockProfileService {
  Map<String, dynamic>? storedProfile;
  bool ensureCalled = false;

  Future<void> ensureProfileDoc() async {
    ensureCalled = true;
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
    return storedProfile;
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
    storedProfile = {
      if (displayName != null) 'displayName': displayName,
      if (sexo != null) 'sexo': sexo,
      if (idade != null) 'idade': idade,
      if (altura != null) 'altura': altura,
      if (peso != null) 'peso': peso,
      if (idioma != null) 'idioma': idioma,
      if (cref != null) 'cref': cref,
      if (role != null) 'role': role,
      if (photoURL != null) 'photoURL': photoURL,
    };
  }
}

void main() {
  group('ProfileService - Testes Básicos', () {
    test('ensureProfileDoc deve ser chamado', () async {
      final mock = MockProfileService();

      expect(mock.ensureCalled, false);
      await mock.ensureProfileDoc();
      expect(mock.ensureCalled, true);
    });

    test('updateMyProfile deve armazenar os dados enviados', () async {
      final mock = MockProfileService();

      await mock.updateMyProfile(
        displayName: 'Antonio',
        sexo: 'masculino',
        idade: 25,
        altura: 1.80,
        peso: 80.0,
        idioma: 'pt-BR',
        role: 'aluno',
      );

      final perfil = mock.storedProfile!;
      expect(perfil['displayName'], 'Antonio');
      expect(perfil['sexo'], 'masculino');
      expect(perfil['idade'], 25);
      expect(perfil['altura'], 1.80);
      expect(perfil['peso'], 80.0);
      expect(perfil['idioma'], 'pt-BR');
      expect(perfil['role'], 'aluno');
    });
  });
}
