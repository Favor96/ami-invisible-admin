import 'package:flutter/material.dart';

class AppTheme {
  // Dégradé principal
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFFD42481), // Couleur 1 : #D42481
      Color(0xFFFD1415), // Couleur 2 : #FD1415
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static  LinearGradient primaryGradientOp = LinearGradient(
    colors: [
     const  Color(0xFFD42481).withOpacity(0.2), // Couleur 1 : #D42481
     const Color(0xFFFD1415).withOpacity(0.2), // Couleur 2 : #FD1415
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Définition des couleurs principales
  static const Color primaryColor =
      Color(0xFFD42481); // Couleur principale (pour d'autres usages)
  static const Color secondaryColor =
      Color(0xFFADAFBB); // Couleur secondaire (ADAFFBB)
  static const Color thirdColor =
      Color(0xFFC4C4C4); // Troisième couleur (C4C4C4)
  static const Color blackColor = Color(0xFF000000); // Noir (000000)
  static const Color whiteColor =
      Colors.white; // Blanc (préfère utiliser Colors.white directement)
  static const Color textColor = Color(0xFF323755); // Blanc (préfère utiliser Colors.white directement)

  // Définition du thème global
  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: whiteColor, 
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme:  IconThemeData(color: whiteColor),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: whiteColor,
        secondary:
            secondaryColor, 
        onSecondary: blackColor,
      ),

      buttonTheme: const ButtonThemeData(
        buttonColor: secondaryColor, // Couleur des boutons
      ),
    );
  }
}
