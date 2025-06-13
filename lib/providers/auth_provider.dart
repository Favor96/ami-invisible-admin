import 'dart:convert';
import 'dart:developer';
import 'package:ami_invisible_admin/services/auth_service.dart';
import 'package:ami_invisible_admin/utils/auth_storage.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _user;
  String? _error;
  int _notifications_unread = 0;
  bool get isLoading => _isLoading;
  String? get token => _token;
  int get notifications_unread => _notifications_unread;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  Map<String, String> _fieldErrors = {};
  Map<String, String> get fieldErrors => _fieldErrors;
  bool _isLoadingOtp = false;
  String? _errorOtp;
  bool get isLoadingOtp => _isLoadingOtp;
  String? get errorOtp => _errorOtp;

  bool _isLoadingUser = false;
  String? _errorUser;
  bool get isLoadingUser => _isLoadingUser;
  String? get errorUser => _errorUser;
  Map<String, dynamic>? _userMap;
  Map<String, dynamic>? get userMap => _userMap;
  bool? _hasProfil;

  bool? get hasProfil => _hasProfil;

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void changeTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

 Future<void> register(
      {required String email,
      required String password,
      required String username,
      required String nom,
      required String prenom,
      required String phone,
      required String gender}) async {
    _isLoading = true;
    _error = null;
    _fieldErrors = {};
    notifyListeners();

    try {
      final response = await _authService.register(
        email: email,
        password: password,
        password_confirmation: password,
        username: username,
        nom: nom,
        prenom: prenom,
        phone: phone,
        gender: gender,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _error = null;
      } else if (response.statusCode == 422) {
        // Laravel : erreurs de validation
          final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['error'] != null && data['error'] is Map) {
          final errors = Map<String, dynamic>.from(data['error']);
          _fieldErrors = {
            for (var entry in errors.entries)
              entry.key: (entry.value as List).first.toString()
          };
        }
        _error = "Erreur de validation ";
      } else {
        _error = "Erreur d'inscription ${response.body}";
      }
    } catch (e) {
      _error = "Erreur réseau ou serveur : $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? email,
    String? username,
    String? nom,
    String? prenom,
    String? phone,
    String? gender,
  }) async {
    _isLoading = true;
    _error = null;
    _fieldErrors = {};
    notifyListeners();

    try {
      final response = await _authService.updateProfile(
        email: email,
        username: username,
        nom: nom,
        prenom: prenom,
        phone: phone,
        gender: gender,
      );
      if (response.statusCode == 200) {
        _error = null;
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['user'] != null) {
          _userMap = Map<String, dynamic>.from(data['user']);
        }

      } else if (response.statusCode == 400) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['message'] != null && data['message'] is Map) {
          final errors = Map<String, dynamic>.from(data['message']);
          _fieldErrors = {
            for (var entry in errors.entries)
              entry.key: (entry.value as List).first.toString()
          };
        }
        _error = "Erreur de validation";
      } else {
        _error = "Erreur lors de la mise à jour : ${response.body}";
      }
    } catch (e) {
      _error = "Erreur réseau ou serveur : $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login({
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _fieldErrors = {};
    notifyListeners();

    try {
      final response =
          await _authService.login(phone: phone, password: password);
      log("Response: ${response.statusCode}");
      log("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userMap = data['admin'];
        _error = null;
        // await AuthService().registerFcmToken();

        await AuthStorage.saveToken(_token!);
        return true;
      } else if (response.statusCode == 401) {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? "Erreur d'authentification";
        _token = null;
        _user = null;
        return false;
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? "Erreur de validation";
        if (data['error'] != null && data['error'] is Map) {
          final errors = Map<String, dynamic>.from(data['error']);
          _fieldErrors = {
            for (var entry in errors.entries)
              entry.key: (entry.value as List).first.toString()
          };
        }
        _error = message;
        _token = null;
        _user = null;
        return false;
      } else {
        _error = "Échec de la connexion ";
        _token = null;
        _user = null;
        return false;
      }
    } catch (e) {
      _error = "Erreur de connexion";
      _token = null;
      _user = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


Future<void> confirmTel({
    required String tel,
    required String code,
    required String password,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    _isLoadingOtp = true;
    _errorOtp = null;
    notifyListeners();

    try {
      final response = await _authService.confirmTel(tel: tel, code: code);

      if (response.statusCode == 200) {
        _errorOtp = null;

        // Tenter de connecter l'utilisateur
        final loginSuccess = await login(phone: tel, password: password);

        if (loginSuccess) {
          onSuccess();
        } else {
          onError("Échec de la connexion après vérification ");
        }
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? "Code incorrect ou expiré";
        _errorOtp = message;
        onError(message);
      } else {
        _errorOtp = "Erreur de vérification";
        onError("Erreur de vérification");
      }
    } catch (e) {
      _errorOtp = "Erreur serveur ou réseau";
      onError("Erreur serveur ou réseau");
    }

    _isLoadingOtp = false;
    notifyListeners();
  }

  Future<void> confirmTel2({
    required String tel,
    required String code,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    _isLoadingOtp = true;
    _errorOtp = null;
    notifyListeners();

    try {
      final response = await _authService.confirmTel(tel: tel, code: code);

      if (response.statusCode == 200) {
        _errorOtp = null;
        onSuccess();

      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? "Code incorrect ou expiré";
        _errorOtp = message;
        onError(message);
      } else {
        _errorOtp = "Erreur de vérification";
        onError("Erreur de vérification");
      }
    } catch (e) {
      _errorOtp = "Erreur serveur ou réseau";
      onError("Erreur serveur ou réseau");
    }

    _isLoadingOtp = false;
    notifyListeners();
  }

  Future<void> confirmEmail({
    required String email,
    required String code,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    _isLoadingOtp = true;
    _errorOtp = null;
    notifyListeners();

    try {
      final response = await _authService.confirmMail(mail: email, code: code);
log("Confirm mail ${response.body}");
      if (response.statusCode == 200) {
        _errorOtp = null;
        onSuccess();
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? "Code incorrect ou expiré";
        _errorOtp = message;
        onError(message);
      } else {
        _errorOtp = "Erreur de vérification";
        onError("Erreur de vérification");
      }
    } catch (e) {
      _errorOtp = "Erreur serveur ou réseau";
      onError("Erreur serveur ou réseau");
    }

    _isLoadingOtp = false;
    notifyListeners();
  }

Future<void> fetchUser() async {
    _isLoadingUser = true;
    _errorUser = null;
    notifyListeners();

    try {
      final response = await AuthService().getUser();
      log("Info ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print("👤 Données utilisateur : ${data['admin']}");
        _userMap = data['admin'];
        _notifications_unread = data['notifications_unread'];
      } else {
        _errorUser =
            "Erreur lors du chargement du profil : ${response.statusCode}";
      }
    } catch (e) {
      _errorUser = "Exception: $e";
    }

    _isLoadingUser = false;
    notifyListeners();
  }



Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    final token = await AuthStorage.getToken();
    log("token $token");
    if (token != null) {
      final response =
          await _authService.logout();
      log("t ${response.body}");
      if (response.statusCode == 200) {
        _token = null;
        _user = null;
        await AuthStorage.clearToken();
        _error = null;
      } else {
        _error = "Erreur lors de la déconnexion";
      }
    } else {
      _error = "Utilisateur non authentifié";
    }

    _isLoading = false;
    notifyListeners();
  }

  

}
