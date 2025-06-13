import 'dart:convert';

class UserNotification {
  final int id;
  final String title;
  final String body;
  final bool is_read;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  UserNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.createdAt,
    required this.is_read
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      data: json['data'] is String
          ? Map<String, dynamic>.from(jsonDecode(json['data']))
          : Map<String, dynamic>.from(json['data']),
      createdAt: DateTime.parse(json['created_at']),
        is_read: json['is_read']
    );
  }
}
