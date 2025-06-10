import 'package:ami_invisible_admin/core/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Si tu utilises go_router pour la navigation

class CustomButton extends StatelessWidget {
  final String buttonText; // Texte du bouton
  final String routeName; // Nom de la route à pousser
  final EdgeInsetsGeometry margin; // Marges personnalisables

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.routeName,
    this.margin = const EdgeInsets.only(bottom: 20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin, // Utilisation de la marge personnalisée
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(50),
      ),
      child: ElevatedButton(
        onPressed: () {
          context.pushNamed(routeName); // Navigation vers la route
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          elevation: 5,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Text(
          buttonText, // Texte du bouton dynamique
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
