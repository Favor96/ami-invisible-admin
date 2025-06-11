import 'dart:convert';

import 'package:ami_invisible_admin/services/constant.dart';
import 'package:ami_invisible_admin/utils/auth_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class ChatService {
  final client = http.Client();

  // Récupérer les messages reçus d'un utilisateur spécifique
  Future<http.Response> getMessagesFromUser(int senderId) async {
    final token = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/messages/$senderId/received');
    return await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  // Récupérer les messages envoyés à un utilisateur spécifique
  Future<http.Response> getMessagesSentToUser(int receiverId) async {
    final token = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/messages/$receiverId/sent');
    return await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  // Envoyer un nouveau message
  Future<http.StreamedResponse> sendMessage({
    required int receiverId,
    required String content,
    List<PlatformFile>? files,
  }) async {
    final token = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/messages');

    var request = http.MultipartRequest('POST', url);

    // Ajout des headers
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // Ajout des champs du formulaire
    request.fields['receiver_id'] = receiverId.toString();
    request.fields['content'] = content;

    // Ajout des fichiers si présents
    if (files != null) {
      for (var file in files) {
        if (file.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath('files[]', file.path!),
          );
        }
      }
    }

    // Envoi de la requête
    return await request.send();
  }
  // Supprimer un message
  Future<http.Response> deleteMessage(int messageId) async {
    final token = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/messages/$messageId/delete');
    return await client.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  // Marquer un message comme lu
  Future<http.Response> markAsRead(int messageId) async {
    final token = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/messages/$messageId/isread');
    return await client.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }
  Future<http.Response> markAllMessageRead(int userId) async {
    final token = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/message/mark-all');
    print("Id $userId");
    return await client.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },

      body: jsonEncode({'sender_id': userId}),
    );
  }

  // Nombre d'expéditeurs avec messages non lus
  Future<http.Response> getUnreadSendersCount() async {
    final token = await AuthStorage.getToken();
    final url = Uri.parse('$BASE_URL/messages/unread-senders-count');
    return await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  // Récupérer un message spécifique
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
}