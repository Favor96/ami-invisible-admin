import 'dart:convert';

import 'package:ami_invisible_admin/providers/auth_provider.dart';
import 'package:ami_invisible_admin/router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

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
      payload: 'local',
    );
  }


  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          try {
            final data = jsonDecode(payload);
            if (data is Map && data.containsKey('sender_id')) {
              final senderId = data['sender_id'].toString();
              _navigateToMessagePage(senderId);
            }
          } catch (e) {
            print("Erreur de parsing du payload : $e");
          }
        }
      },
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // ✅ App en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // ✅ App en background (notification cliquée)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final data = message.data;
      if (data.containsKey('sender_id')) {
        final senderId = data['sender_id'].toString();
        _navigateToMessagePage(senderId);
      }
    });

    // ✅ App terminée (notification cliquée au lancement)
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final data = initialMessage.data;
      if (data.containsKey('sender_id')) {
        final senderId = data['sender_id'].toString();
        _navigateToMessagePage(senderId);
      }
    }
  }


  /// ✅ Gestion d’un message Firebase en foreground
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      // 👇 Encodage JSON du payload data
      final String jsonPayload = jsonEncode(data);

      _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'fcm_channel',
            'Messages',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: jsonPayload, // 👈 On envoie les données en JSON
      );
    }
  }

  void _navigateToMessagePage(String senderId) {
    Future.delayed(const Duration(milliseconds: 500), () {
      final context = navigatorKey.currentContext;
      if (context != null) {
        final controller = Provider.of<AuthProvider>(context, listen: false);
        controller.changeTab(2); // Onglet "Messages"
      }
    });
  }
}
