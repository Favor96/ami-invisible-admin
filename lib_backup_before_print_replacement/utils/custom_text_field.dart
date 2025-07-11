import 'package:ami_invisible_admin/core/config/app_theme.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String validationMessage;
  final IconData? prefixIcon; // Icône optionnelle
  final Color? borderColor; // Couleur de la bordure
  final TextStyle? labelStyle; // Style de l'étiquette
  final bool isReadOnly; // Si le champ est en lecture seule
  final Function()? onTap; // Action lors du clic
  final TextInputType keyboardType; // Type de clavier
   final FormFieldValidator<String>? validator;
   final String? errorText;
   final bool enableValidation;



  // Constructeur du widget
  const CustomTextFormField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.validationMessage,
    this.prefixIcon,
    this.borderColor,
    this.labelStyle,
    this.isReadOnly = false,
    this.onTap,
    this.validator,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.enableValidation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: isReadOnly,
      decoration: InputDecoration(
        labelText: labelText,
        errorText: errorText,
        labelStyle: labelStyle ??
            TextStyle(
              fontSize: 14, color: Colors.black, // Valeur par défaut
            ),
        prefixIcon: prefixIcon != null
            ? ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: Icon(
                  prefixIcon,
                  color: Colors.white, // Icône en blanc
                ),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: borderColor ?? Color(0xFFADAFBB), // Couleur par défaut
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: borderColor ?? Color(0xFFADAFBB),
            width: 2.0,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: borderColor ?? Color(0xFFADAFBB),
            width: 0,
          ),
        ),
      ),
      validator: enableValidation
          ? (validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return validationMessage;
                }
                return null;
              })
          : null,
      onTap: onTap,
    );
  }
}
