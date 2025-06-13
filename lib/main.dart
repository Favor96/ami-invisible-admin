import 'package:ami_invisible_admin/core/config/app_theme.dart';
import 'package:ami_invisible_admin/providers/admin_provider.dart';
import 'package:ami_invisible_admin/providers/auth_provider.dart';
import 'package:ami_invisible_admin/providers/chat_provider.dart';
import 'package:ami_invisible_admin/providers/notification_provider.dart';
import 'package:ami_invisible_admin/router.dart';
import 'package:ami_invisible_admin/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(" Message reçu en arrière-plan: ${message.messageId}");
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService().init();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.white, // Barre de statut blanche
    statusBarIconBrightness: Brightness.dark, // Icônes foncées
    systemNavigationBarColor: const Color(0xFFC4C4C4), // Barre de navigation blanche
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  await initializeDateFormatting('fr_FR', null);
  runApp(
    MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => AdminProvider()),
      ChangeNotifierProvider(create: (_) => ChatProvider()),
      ChangeNotifierProvider(create: (_) => NotificationProvider()),
      // Tu peux ajouter d'autres providers ici
    ],
    child: const MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ami Invisible Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: router,
    );
  }
}