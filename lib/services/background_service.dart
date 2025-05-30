import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> setupNotificationChannel() async {
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_channel_id',
    'Descarga en segundo plano',
    description: 'Notificaciones para descargas en background',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_channel_id',
      initialNotificationTitle: 'Descarga en background',
      initialNotificationContent: 'El servicio está corriendo',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
bool onIosBackground(ServiceInstance service) {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Descarga en background",
      content: "Servicio activo",
    );
  }

  service.on('download').listen((event) async {
    final url = event?['url'] as String?;
    final filename = event?['filename'] as String?;

    if (url == null || filename == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');

    try {
      final request = await http.Client().send(http.Request('GET', Uri.parse(url)));
      final contentLength = request.contentLength ?? 0;
      int downloaded = 0;

      final sink = file.openWrite();

      // 🔔 Mostrar notificación de inicio
      flutterLocalNotificationsPlugin.show(
        0,
        'Descargando...',
        filename,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'my_channel_id',
            'Descarga en segundo plano',
            importance: Importance.low,
            priority: Priority.low,
            onlyAlertOnce: true,
            showProgress: true,
            maxProgress: 100,
            progress: 0,
          ),
        ),
      );

      request.stream.listen((chunk) {
        sink.add(chunk);
        downloaded += chunk.length;

        double progress = contentLength > 0 ? downloaded / contentLength : 0;

        service.invoke('downloadProgress', {
          'filename': filename,
          'progress': progress,
        });

        // 🔔 Actualizar notificación con progreso
        flutterLocalNotificationsPlugin.show(
          0,
          'Descargando...',
          filename,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'my_channel_id',
              'Descarga en segundo plano',
              importance: Importance.low,
              priority: Priority.low,
              onlyAlertOnce: true,
              showProgress: true,
              maxProgress: 100,
              progress: (progress * 100).toInt(),
            ),
          ),
        );
      }, onDone: () async {
        await sink.close();
        service.invoke('downloadComplete', {'filename': filename});

        // Muestra notificación de completado
        flutterLocalNotificationsPlugin.show(
          0,
          'Descarga completa',
          filename,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_channel_id',
              'Descarga en segundo plano',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }, onError: (e) {
        service.invoke('downloadError', {'error': e.toString()});

        // Muestra notificación de error
        flutterLocalNotificationsPlugin.show(
          0,
          'Error al descargar',
          e.toString(),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_channel_id',
              'Descarga en segundo plano',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      });
    } catch (e) {
      service.invoke('downloadError', {'error': e.toString()});
    }
  });
}
