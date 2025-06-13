import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  // ✅ Canal pour Android 8+
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'fcm_channel',
    'Messages',
    description: 'Ce canal est utilisé pour les notifications des messages.',
    importance: Importance.high,
  );


  Future<void> showLocalNotification(
      {required String title, required String body}) async {
    await _localNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fcm_channel',
          'Messages',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: 'local', // 👈 On indique que c'est une notification locale
    );
  }

  /// ✅ Initialisation du service de notification
  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    // ✅ Initialisation du plugin local avec gestion du payload
    await _localNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;

        if (payload == 'firebase') {
          print("🔥 Notification reçue depuis Firebase");
        } else if (payload == 'local') {
          print("📱 Notification locale manuelle");
        } else {
          print("🔔 Notification inconnue ou sans payload");
        }
      },
    );

    // ✅ Création du canal (Android 8+)
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // ✅ Écoute des messages reçus quand l'app est en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  /// ✅ Gestion d’un message Firebase en foreground
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'fcm_channel', // channel ID
            'Messages', // channel name
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: 'firebase', // 👈 On indique que ça vient de Firebase
      );
    }
  }
}
