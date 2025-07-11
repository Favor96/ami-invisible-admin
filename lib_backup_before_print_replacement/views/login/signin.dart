import 'package:ami_invisible_admin/core/config/app_theme.dart';
import 'package:ami_invisible_admin/core/config/text_style.dart';
import 'package:ami_invisible_admin/providers/auth_provider.dart';
import 'package:ami_invisible_admin/services/auth_service.dart';
import 'package:ami_invisible_admin/utils/custom_text_field.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class Signin extends StatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedCountryCode = "+228"; // Code par défaut
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget _buildLoadingModal() {
    return Dialog(
      backgroundColor: Colors.transparent, // Fond transparent
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity, // Prend tout l'écran
        color: Colors.black.withOpacity(0.5), // Fond assombri
        child: const Center(
          child: CircularProgressIndicator(), // Loader centré
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final fieldErrors = context.watch<AuthProvider>().fieldErrors;
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: screenSize.width,
            height: screenSize.height,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset(
                  'assets/img/logo.png', // Remplace par le chemin de ton logo
                  height: 100,
                ),
                const SizedBox(height: 20),
                Text(
                  "Se connecter",
                  style: AppTextStyles.h4Bold.copyWith(color: AppTheme.blackColor),
                ),
                const SizedBox(height: 30),
                Form(
                    key: formkey,
                    child: Column(
                      children: [
                        CustomTextFormField(
                          controller: _email,
                          errorText: fieldErrors['email'],
                          keyboardType: TextInputType.emailAddress,
                          labelText: "Email",
                          validationMessage: "Ce champ est requis",
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.blackColor,
                          ),
                          borderColor: const Color(0xFFADAFBB),
                          // errorText: fieldErrors['password'],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "L'email est requis";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomTextFormField(
                          controller: _passwordController,
                          errorText: fieldErrors['password'],
                          labelText: "Mot de passe",
                          keyboardType: TextInputType.visiblePassword,
                          validationMessage: "Ce champ est requis",
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.blackColor,
                          ),
                          borderColor: const Color(0xFFADAFBB),
                          // errorText: fieldErrors['password'],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Le mot de passe est requis";
                            }
                            if (value.length < 6) {
                              return "Le mot de passe doit contenir au moins 6 caractères";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    )
                ),
                const Spacer(),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formkey.currentState!.validate()) {
                            return;
                          }

                          final authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                          final String fullPhone = _email.text;
                          final String password = _passwordController.text;

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => _buildLoadingModal(),
                          );

                          final success = await authProvider.login(
                            phone: fullPhone,
                            password: password,
                          );
                          await AuthService().registerFcmToken();

                          if (!success) {
                            Navigator.of(context).pop(); // Fermer le loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    authProvider.error ?? "Erreur de connexion"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            await authProvider.fetchUser();
                            Navigator.of(context).pop(); // Fermer le loading
                              context.goNamed(
                                  'layout');
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Center(
                          child: Text(
                            "Se connecter",
                            style:
                            AppTextStyles.h5Bold.copyWith(color: Colors.white),
                          ),
                        ),
                      ),

                    )),


                const SizedBox(height: 15),
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Terms of use",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Privacy Policy",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
