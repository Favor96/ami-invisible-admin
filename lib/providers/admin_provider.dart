import 'dart:convert';
import 'dart:developer';

import 'package:ami_invisible_admin/services/admin_service.dart';
import 'package:flutter/material.dart';

class AdminProvider with ChangeNotifier {

  final AdminService adminService = AdminService();
  List<dynamic> _verifiedUsers = [];
  int _totalVerifiedUsers = 0;
  List<dynamic> _matchs = [];
  List<dynamic> _payementList = [];
  int _totalMatch = 0;
  int _totalMatchUnPaid = 0;
  int _totalMatchAmountPaid = 0;
  bool _isLoading = false;
  String? _error;

  List<dynamic> get verifiedUsers => _verifiedUsers;
  int get totalVerifiedUsers => _totalVerifiedUsers;
  List<dynamic> get matchs => _matchs;
  List<dynamic> get payements => _payementList;
  int get totalMatch => _totalMatch;
  int get totalMatchUnPaid => _totalMatchUnPaid;
  int get totalMatchAmountPaid => _totalMatchAmountPaid;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Map<String,dynamic>>? _chatAllMessage;
  List<Map<String,dynamic>>? get chatAllMessage => _chatAllMessage;

  List<Map<String, dynamic>> get allLikes => _allLikes;
  List<Map<String, dynamic>> _allLikes = [];
  Future<void> fetchVerifiedUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await adminService.getUsers();
      log("response b ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        _error = null;
        final Map<String, dynamic> data = jsonDecode(response.body);
        _verifiedUsers = data['users'];
        _totalVerifiedUsers = data['total_verified_users'];

      } else {
        _error = "Erreur ${response.body}";
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPayements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await adminService.getPayement();
      log("response b ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        _error = null;
        final Map<String, dynamic> data = jsonDecode(response.body);
        _payementList = data['data'];

      } else {
        _error = "Erreur ${response.body}";
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void reorderUserOnNewMessage(int userId, Map<String, dynamic> newMessage,
      {bool sentByMe = false}) {
    final index = _verifiedUsers.indexWhere((u) => u['id'] == userId);
    print("Index $index");

    if (index != -1) {
      final user = _verifiedUsers[index];

      user['last_message'] = newMessage;

      if (!sentByMe) {
        int currentUnread = user['unread_messages_count'] ?? 0;
        user['unread_messages_count'] = currentUnread + 1;
      }

      user['last_message_sent_by_me'] = sentByMe;
      print("user $user");

      _verifiedUsers.removeAt(index);

      _verifiedUsers.insert(0, user);

      notifyListeners();
    }
  }

  Future<void> fetchMatchs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await adminService.getMatchs();
      log("response ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _error = null;
        final Map<String, dynamic> data = jsonDecode(response.body);
        _matchs = data['matches'];
        _totalMatch = data['total_match'];
        _totalMatchAmountPaid = data['total_paid_amount'];
        _totalMatchUnPaid = data['unpaid_match_count'];

      } else {
        _error = "Erreur ${response.body}";
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchChatMessage(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await adminService.getChatMessage(userId);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> messageList = responseData['message'] ?? [];

        _chatAllMessage = messageList
            .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
            .toList();
        notifyListeners();
      } else {
        _error = "Erreur ${response.statusCode} lors du chargement du message";
      }
    } catch (e) {
      _error = "Exception: $e";
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllLikes(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await adminService.getAllLikes(id);
      if (response.statusCode == 200) {
        final data= jsonDecode(response.body);
        print("dat $data");
        final users = List<Map<String, dynamic>>.from(data['users']);

        _allLikes = users;
      } else {
        print("Err ${response.body}");
        _error =
        "Erreur ${response.body} lors du chargement de tous les likes.";
      }
    } catch (e) {
      _error = "Exception: $e";
    }
    _isLoading = false;
    notifyListeners();
  }


  void clearMessages() {
    _chatAllMessage = [];
    _error = null;
    notifyListeners();
  }
}