import 'package:houbago/houbago/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

enum NotificationType {
  earning(
    color: Colors.green,
    icon: Icons.attach_money,
  ),
  withdrawal(
    color: Colors.orange,
    icon: Icons.account_balance_wallet,
  ),
  affiliation(
    color: Colors.blue,
    icon: Icons.people,
  ),
  system(
    color: Colors.grey,
    icon: Icons.info,
  );

  const NotificationType({
    required this.color,
    required this.icon,
  });

  final Color color;
  final IconData icon;
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: _getNotificationType(json['type'] as String),
      read: json['read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static NotificationType _getNotificationType(String type) {
    switch (type) {
      case 'earning':
        return NotificationType.earning;
      case 'withdrawal':
        return NotificationType.withdrawal;
      case 'affiliation':
        return NotificationType.affiliation;
      case 'system':
      default:
        return NotificationType.system;
    }
  }
}

class HoubagoNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;

  const HoubagoNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  factory HoubagoNotification.fromJson(Map<String, dynamic> json) {
    return HoubagoNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'read': read,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Données de test
final List<NotificationModel> dummyNotifications = [
  NotificationModel(
    id: '1',
    title: 'Nouveau gain',
    message: '15 000 FCFA pour votre dernière course',
    type: NotificationType.earning,
    read: false,
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
  NotificationModel(
    id: '2',
    title: 'Retrait effectué',
    message: 'Votre retrait de 50 000 FCFA a été traité avec succès',
    type: NotificationType.withdrawal,
    read: true,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  NotificationModel(
    id: '3',
    title: 'Nouveau parrainage',
    message: 'Félicitations ! Votre filleul Koffi a effectué sa première course',
    type: NotificationType.affiliation,
    read: false,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  NotificationModel(
    id: '4',
    title: 'Mise à jour système',
    message: 'Une nouvelle version de l\'application est disponible',
    type: NotificationType.system,
    read: true,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];
