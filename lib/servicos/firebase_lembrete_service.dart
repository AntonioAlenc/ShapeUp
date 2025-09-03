import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;

class FirebaseLembreteService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initOk = false;

  // Inicialização
  static Future<void> init() async {
    if (_initOk) return;
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);

    await _plugin.initialize(settings);
    _initOk = true;

    if (Platform.isAndroid) {
      final impl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await impl?.requestNotificationsPermission();
    }
  }

  /// Agenda notificações semanais para os dias informados (1=Seg .. 7=Dom)
  static Future<void> agendarParaDiasSemana({
    required int idBase,
    required String titulo,
    required String mensagem,
    required List<int> diasSemana,
    required String horarioHHmm,
  }) async {
    await init();
    final parts = horarioHHmm.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'treinos_channel',
        'Lembretes de Treino',
        channelDescription: 'Notificações para horário de treino',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    for (final d in diasSemana) {
      final id = idBase + d;
      await _plugin.zonedSchedule(
        id,
        titulo,
        mensagem,
        _proximaDataSemanal(d, h, m),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static tz.TZDateTime _proximaDataSemanal(int diaSemana, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduled.weekday != diaSemana || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
