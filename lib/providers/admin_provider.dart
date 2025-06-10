import 'dart:convert';
import 'dart:developer';

import 'package:ami_invisible_admin/services/admin_service.dart';
import 'package:flutter/material.dart';

class AdminProvider with ChangeNotifier {

  final AdminService adminService = AdminService();
  List<dynamic> _verifiedUsers = [];
  int _totalVerifiedUsers = 0;
  List<dynamic> _matchs = [];
  int _totalMatch = 0;
  int _totalMatchUnPaid = 0;
  int _totalMatchAmountPaid = 0;
  bool _isLoading = false;
  String? _error;

  List<dynamic> get verifiedUsers => _verifiedUsers;
  int get totalVerifiedUsers => _totalVerifiedUsers;
  List<dynamic> get matchs => _matchs;
  int get totalMatch => _totalMatch;
  int get totalMatchUnPaid => _totalMatchUnPaid;
  int get totalMatchAmountPaid => _totalMatchAmountPaid;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
}