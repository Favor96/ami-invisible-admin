import 'dart:convert';

import 'package:ami_invisible_admin/services/chat_service.dart';
import 'package:ami_invisible_admin/services/reverb_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  bool _isLoading = false;
  String? _error;

  List<dynamic> _receivedMessages = [];
  List<dynamic> _sentMessages = [];
  int _unreadSendersCount = 0;
  Map<String, dynamic>? _chatMessage;
  List<Map<String,dynamic>>? _chatAllMessage;
  List<Map<String,dynamic>>? get chatAllMessage => _chatAllMessage;


  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get receivedMessages => _receivedMessages;
  List<dynamic> get sentMessages => _sentMessages;
  int get unreadSendersCount => _unreadSendersCount;
  Map<String, dynamic>? get chatMessage => _chatMessage;
  int? _currentOpenUserId;
  int? get currentOpenUserId => _currentOpenUserId;

  void setCurrentOpenUserId(int? userId) {
    _currentOpenUserId = userId;
  }



  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchReceivedMessages(int senderId) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _chatService.getMessagesFromUser(senderId);
      if (response.statusCode == 200) {
        _receivedMessages = jsonDecode(response.body);
      } else {
        _error =
        "Erreur ${response.statusCode} lors du chargement des messages reçus";
      }
    } catch (e) {
      _error = "Exception: $e";
    }
    _setLoading(false);
  }

  Future<void> fetchSentMessages(int receiverId) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _chatService.getMessagesSentToUser(receiverId);
      if (response.statusCode == 200) {
        _sentMessages = jsonDecode(response.body);
      } else {
        _error =
        "Erreur ${response.statusCode} lors du chargement des messages envoyés";
      }
    } catch (e) {
      _error = "Exception: $e";
    }
    _setLoading(false);
  }

  Future<bool> sendMessage(int receiverId, String content,
      {List<PlatformFile>? files}) async {
    _error = null;
    try {
      final streamedResponse = await _chatService.sendMessage(
        receiverId: receiverId,
        content: content,
        files: files,
      );

      final responseBody = await streamedResponse.stream.bytesToString();
      final statusCode = streamedResponse.statusCode;

      print("resp $statusCode - $responseBody");

      if (statusCode == 200 || statusCode == 201) {
        return true;
      } else {
        _error = "Erreur $statusCode lors de l'envoi du message";
        return false;
      }
    } catch (e) {
      _error = "Exception: $e";
      print("Err $_error");
      return false;
    }
  }


  Future<bool> deleteMessage(int messageId) async {
    _error = null;
    try {
      final response = await _chatService.deleteMessage(messageId);
      if (response.statusCode == 200) {
        return true;
      } else {
        _error =
        "Erreur ${response.statusCode} lors de la suppression du message";
        return false;
      }
    } catch (e) {
      _error = "Exception: $e";
      return false;
    }
  }

  Future<bool> markMessageAsRead(int messageId) async {
    _error = null;
    try {
      final response = await _chatService.markAsRead(messageId);
      if (response.statusCode == 200) {
        return true;
      } else {
        _error = "Erreur ${response.statusCode} lors du marquage comme lu";
        return false;
      }
    } catch (e) {
      _error = "Exception: $e";
      return false;
    }
  }
  Future<bool> markAllMessageAsRead(int userId) async {
    _error = null;
    try {
      final response = await _chatService.markAllMessageRead(userId);
      print("Respo un ${response.body}");
      if (response.statusCode == 200) {
        return true;
      } else {
        _error = "Erreur ${response.statusCode} lors du marquage comme lu";
        return false;
      }
    } catch (e) {
      _error = "Exception: $e";
      return false;
    }
  }

  Future<void> fetchUnreadSendersCount() async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _chatService.getUnreadSendersCount();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _unreadSendersCount =
        data != null && data['unread_senders_count'] != null ? data['unread_senders_count'] as int : 0;
      } else {
        _error =
        "Erreur ${response.statusCode} lors du chargement du nombre d'expéditeurs non lus";
      }
    } catch (e) {
      _error = "Exception: $e";
    }
    _setLoading(false);
  }

  void decrementUnreadSendersCount() {
    if (_unreadSendersCount > 0) {
      _unreadSendersCount -= 1;
      notifyListeners();
    }
  }

  Future<void> fetchChatMessage(int userId) async {
    _setLoading(true);
    _error = null;
    try {
      final response = await _chatService.getChatMessage(userId);
      print("message ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> messageList = responseData['message'] ?? [];

        print("me ${messageList}");
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
    _setLoading(false);
  }

  void clearMessages() {
    _chatAllMessage = [];
    _error = null;
    notifyListeners();
  }

  final ReverbService _reverbService = ReverbService();

  Future<void> connectToSocket(String channelName,) async {
    await _reverbService.connect();
    await _reverbService.subscribeToPrivateChannel(channelName);

    _reverbService.stream.listen((data) async {
      final decoded = jsonDecode(data);
      print("Web sco receib $decoded");
      print("Web socket received event: ${decoded['event']}");

      if (decoded['event'] == 'chat-message') {
        final eventData =
        jsonDecode(decoded['data']); // d'abord parser la string JSON
        final msg = eventData['message'];
        if(msg != null) {
          if (_chatAllMessage != null) {
            _chatAllMessage!.add({
              'content': msg['content'],
              'files': msg['files'],
              'created_at': msg['created_at'],
              'isMe': false,
            });
            if (_currentOpenUserId != null &&
                msg['sender_id'] == _currentOpenUserId) {
              await markMessageAsRead(msg['sender_id']);
              _chatAllMessage!.last['is_read'] = 1;
              notifyListeners();
            }
            notifyListeners();
          }
          Map<String, dynamic> message = {
            'id': DateTime
                .now()
                .millisecondsSinceEpoch,
            'sender_id': msg['sender_id'],
            'receiver_id': msg['receiver_id'],
            'content': msg['content'],
            'is_read': msg['is_read'],
            'isDeleted': 0,
            'created_at': msg['created_at'],
          };

          //   likeProvider.reorderUserOnNewMessage(msg['sender_id'], message, sentByMe: false);
          //
          //   // NotificationService().showLocalNotification(
          //   //   title: "Nouveau message",
          //   //   body: msg['content'],
          //   // );
          //
          // }

        }}});
  }
}
