import 'dart:developer';

import 'package:ami_invisible_admin/utils/auth_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ami_invisible_admin/services/constant.dart';
class AdminService {
  final client = http.Client();

  Future<http.Response> getUsers() async {
    final token = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/verified-users');
    log("ROTK $token");
    return await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  Future<http.Response> getMatchs() async {
    final token = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/matchs');
    return await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  Future<http.Response> getChatMessage(int messageId) async {
    final token = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/message/user/$messageId');
    return await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  Future<http.Response> getAllLikes(int id) async {
    final token = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/likes/all/${id}');

    return await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }
}