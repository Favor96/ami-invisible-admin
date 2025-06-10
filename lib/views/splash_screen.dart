import 'package:ami_invisible_admin/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      checkTokenAndNavigate();
    });
  }

  void checkTokenAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;

    if (!hasSeenIntro) {
      await prefs.setBool('hasSeenIntro', true);
      context.goNamed('signin'); // ou une autre page d'introduction si besoin
      return;
    }

    final authService = AuthService();
    final isValid = await authService.isTokenValid();

    if (!mounted) return;

    if (isValid) {
      context.goNamed('layout'); // Redirige vers l'accueil
    } else {
      context.goNamed('signin'); // Redirige vers la connexion
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Image.asset(
          'assets/img/splash.png',
          width: 120,
          height: 120,
        ),
      ),
    );
  }
}
