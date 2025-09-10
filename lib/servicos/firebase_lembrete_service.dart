import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseLembreteService {
  static final FlutterLocalNotificationsPlugin _notificacoes =
      FlutterLocalNotificationsPlugin();

  /// Inicializa notificações locais (somente no Android/iOS).
  static Future<void> init() async {
    if (kIsWeb) {
      // Web não suporta notificações locais → apenas ignora
      return;
    }

    if (!(Platform.isAndroid || Platform.isIOS)) {
      return;
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _notificacoes.initialize(initSettings);
  }

  /// Exemplo: agendar notificação local
  static Future<void> agendarNotificacao({
    required String titulo,
    required String corpo,
    int id = 0,
  }) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'canal_principal',
      'Lembretes',
      channelDescription: 'Notificações de treinos e dietas',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificacaoDetalhes = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificacoes.show(id, titulo, corpo, notificacaoDetalhes);
  }

  static Future<void> agendarParaDiasSemana(
      {required int idBase,
      required String titulo,
      required String mensagem,
      required List<int> diasSemana,
      required String horarioHHmm}) async {}
}
