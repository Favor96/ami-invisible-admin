import 'dart:convert';
import 'dart:developer';
import 'package:ami_invisible_admin/model/notification.dart';
import 'package:ami_invisible_admin/services/auth_service.dart';
import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  List<UserNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<UserNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService().getUserNotification();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log("Notification of user $data");
        final List notifList = data['data']['data'];

        _notifications = notifList
            .map((item) => UserNotification.fromJson(item))
            .toList();
      } else {
        _error = 'Erreur lors de la récupération (${response.statusCode})';
      }
    } catch (e) {
      _error = 'Erreur : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
