import 'package:ami_invisible_admin/views/interaction_screen.dart';
import 'package:ami_invisible_admin/views/layout_screen.dart';
import 'package:ami_invisible_admin/views/login/signin.dart';
import 'package:ami_invisible_admin/views/message_screen.dart';
import 'package:ami_invisible_admin/views/notification_screen.dart';
import 'package:ami_invisible_admin/views/payement_screen.dart';
import 'package:ami_invisible_admin/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GoRouter router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/', // Définir la route de départ
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
        path: '/notification',
        builder: (context, state) =>  NotificationUserScreen(),
        name: 'notification'),
    GoRoute(
        path: '/signin',
        builder: (context, state) => const Signin(),
        name: 'signin'),
    GoRoute(
        path: '/layout',
        builder: (context, state) => const LayoutScreen(),
        name: 'layout'),
    GoRoute(
      path: '/interactions',
      name: 'interactions',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final interactions = extra['interactions'] as List<dynamic>;
        final username = extra['username'] as String;
        final id = extra['id'] as int;
        return InteractionsPage(
          interactions: interactions,
          username: username,
          id: id,
        );
      },
    ),
    GoRoute(
        path: '/payement',
        builder: (context, state) =>  PayementScreen(),
        name: 'payement'),
    GoRoute(
        path: '/message',
        builder: (context, state) =>  MessageScreen(),
        name: 'message'),
  ],
);
