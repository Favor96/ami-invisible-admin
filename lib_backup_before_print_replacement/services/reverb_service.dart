import 'dart:async';
import 'dart:convert';

import 'package:ami_invisible_admin/services/constant.dart';
import 'package:ami_invisible_admin/utils/auth_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
class ReverbService {
  late WebSocketChannel _channel;
  late StreamController _controller;
  String? _socketId;

  Future<void> connect() async {
    final token = await AuthStorage.getToken();
    if (token == null) throw Exception('No auth token available');

    final host = BASE_URL_REV
        .replaceFirst(RegExp(r'https?://'), '')
        .replaceFirst('/api', '');
    print("Host $host");

    final wsUrl = 'wss://$host/app/$REVERB_APP_KEY';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _controller = StreamController.broadcast();

    final completer = Completer<void>();

    _channel.stream.listen(
          (message) {
        _handleSocketMessage(message, token);
        _controller.add(message); // Diffusion vers le stream du provider

        try {
          final data = jsonDecode(message);
          if (data['event'] == 'pusher:ping') {
            final pong = jsonEncode({'event': 'pusher:pong', 'data': {}});
            _channel.sink.add(pong);
            print("📡 Pong envoyé en réponse au ping");
          }
          if (data['event'] == 'pusher:connection_established') {
            _socketId = jsonDecode(data['data'])['socket_id'];
            print('Connected with Socket ID: $_socketId');
            if (!completer.isCompleted) {
              completer.complete();
            }
          }
        } catch (_) {}
      },
      onError: (error) {
        print('WebSocket Error: $error');
        _controller.addError(error);
      },
    );

    return completer.future;
  }

  void _handleSocketMessage(dynamic message, String token) async {
    try {
      final data = jsonDecode(message);

      if (data['event'] == 'pusher:connection_established') {
        _socketId = jsonDecode(data['data'])['socket_id'];
        print('Connected with Socket ID: $_socketId');
      }

      // Autres traitements ici
    } catch (e) {
      print('Message processing error: $e');
    }
  }

  Future<void> subscribeToPrivateChannel(String channelName) async {
    final token = await AuthStorage.getToken();
    if (_socketId == null || token == null) {
      throw Exception('Not authenticated or not connected');
    }

    final authToken = await _getAuthToken(channelName, token);

    _channel.sink.add(jsonEncode({
      'event': 'pusher:subscribe',
      'data': {
        'auth': authToken,
        'channel': channelName,
      },
    }));
  }

  Future<String> _getAuthToken(String channelName, String token) async {
    final uri = Uri.parse('$BASE_URL_2/broadcasting/auth');
print("sok $_socketId");
print("ch $channelName");
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'socket_id': _socketId,
        'channel_name': channelName,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['auth'];
    } else {
      throw Exception('Auth failed: ${response.statusCode} - ${response.body}');
    }
  }

  Stream get stream => _controller.stream;

  void dispose() {
    _channel.sink.close();
    _controller.close();
  }
}
