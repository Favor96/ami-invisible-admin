import 'dart:convert';
import 'dart:developer';
import 'package:ami_invisible_admin/services/constant.dart';
import 'package:ami_invisible_admin/utils/auth_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final client = http.Client();

  Future<http.Response> register({
    required String email,
    required String password,
    required String password_confirmation,
    required String username,
    required String nom,
    required String prenom,
    required String phone,
    required String gender
  }) async {
    final url = Uri.parse('$BASE_URL/register');
    return await client.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        'email': email,
        'password': password,
        'username': username,
        'nom': nom,
        'prenom': prenom,
        'password_confirmation': password_confirmation,
        'phone': phone,
        'gender': gender,
      },
    );
  }

  Future<http.Response> updateProfile({
    String? email,
    String? username,
    String? nom,
    String? prenom,
    String? phone,
    String? gender,
  }) async {
    final token = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/user/update');

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final Map<String, String> body = {};

    if (email != null) body['email'] = email;
    if (username != null) body['username'] = username;
    if (nom != null) body['nom'] = nom;
    if (prenom != null) body['prenom'] = prenom;
    if (phone != null) body['phone'] = phone;
    if (gender != null) body['gender'] = gender;

    return await client.put(
      url,
      headers: headers,
      body: body,
    );
  }


  Future<http.Response> confirmTel({
    required String tel,
    required String code,
  }) async {
    final url = Uri.parse('$BASE_URL/register/confirm-tel/$tel');
    return await client.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {'verification_code': code},
    );
  }


  Future<http.Response> resentCode({
    required String email,
  }) async {
    final url = Uri.parse('$BASE_URL/resend-code');
    return await client.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {'email': email},
    );
  }

  Future<http.Response> resentCodePhone({
    required String phone,
  }) async {
    final url = Uri.parse('$BASE_URL/resend-code-phone');
    return await client.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {'phone': phone},
    );
  }

  Future<http.Response> confirmMail({
    required String mail,
    required String code,
  }) async {
    final url = Uri.parse('$BASE_URL/register/confirm-email/$mail');
    return await client.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {'verification_code': code},
    );
  }

  Future<http.Response> login({
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$BASE_URL/login');
    final response = await client.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        'email': phone,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['token'] != null) {
        await AuthStorage.saveToken(data['token']);
      }
    }

    return response;
  }

  Future<http.Response> forgotPassword(String email) async {
    final token = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/forgot-password');
    return await client.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: {'email': email},
    );
  }

  Future<http.Response> resetToken(String token) async {
    final accessToken = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/reset-password/$token');
    return await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );
  }

  Future<http.Response> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final accessToken = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/reset-password');
    return await client.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
      body: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  Future<http.Response> logout() async {
    final token = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/logout');
    final response = await client.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    await AuthStorage.clearToken();
    return response;
  }

  Future<http.Response> getUser() async {
    final token = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/admin/info');
    return await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }
  Future<http.Response> getUserVerify() async {
    final token = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/verified-users');
    return await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  Future<http.Response> getUserNotification() async {
    final token = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/user/notifications');
    return await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

Future<bool> isTokenValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$BASE_URL/check-token'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      log("Tokn ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['valid'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('Erreur lors de la vérification du token : $e');
      return false;
    }
  }


// Future<void> signInWithGoogle({
//     required Future<void> Function(bool hasProfil) onSuccess,
//     required Function(String message) onError,
//   }) async {
//     try {
//       final authUrl = '$BASE_URL/oauth/google/redirect';
//
//       final result = await FlutterWebAuth2.authenticate(
//         url: authUrl,
//         callbackUrlScheme: "myapp",
//         options: const FlutterWebAuth2Options(
//           timeout: 5,
//         ),
//       );
//
//       final uri = Uri.parse(result);
//       final token = uri.queryParameters['token'];
//       final hasProfilString = uri.queryParameters['has_profil'];
//
//       if (token != null && token.isNotEmpty) {
//         await AuthStorage.saveToken(token);
//         print("Token Google: $token");
//
//         // Vérifie la présence et la valeur du paramètre `has_profil`
//         final hasProfil = hasProfilString == '1';
//         onSuccess(hasProfil);
//       } else {
//         onError("Échec de la récupération du token.");
//       }
//     } catch (e) {
//       onError("Erreur d'authentification : ${e.toString()}");
//     }
//   }
  Future<void> signInWithGoogle({
    required Future<void> Function(bool hasProfil) onSuccess,
    required Function(String message) onError,
    required BuildContext context,
  }) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: ['email', 'profile'],
      ).signIn();

      log("User $googleUser");
      if (googleUser == null) {
        onError("Connexion annulée");
        return;
      }
      showDialog(
        context: context, // ou ton BuildContext si tu es dans un widget
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.accessToken;

      if (idToken == null) {
        onError("Aucun token d'identification reçu");
        return;
      }

      final response = await http.post(
        Uri.parse('$BASE_URL/oauth/google/callback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}),
      );

      log("Response dat ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await AuthStorage.saveToken(data['token']);

        final hasProfil = data['has_profil'] ?? false;
        onSuccess(hasProfil);
      } else {
        onError("Erreur du serveur: ${response.statusCode}");
      }
    } catch (e) {
      onError("Erreur d'authentification : ${e.toString()}");
      rethrow;
    }
  }
Future<void> registerFcmToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print("token $fcmToken");
     final token = await AuthStorage.getToken();
    if (fcmToken != null) {
      final response = await http.post(
        Uri.parse('$BASE_URL/fcm/register'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': fcmToken}),
      );

      if (response.statusCode == 200) {
        print('Token enregistré ');
      } else {
        print('Échec enregistrement token: ${response.body}');
      }
    }
  }


}
