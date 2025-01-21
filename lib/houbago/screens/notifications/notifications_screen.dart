import 'package:flutter/material.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:houbago/houbago/models/notification.dart';
import 'package:houbago/houbago/ui_view/notifications_list.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: DatabaseService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Une erreur est survenue',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              // Forcer le rebuild du FutureBuilder
              setState(() {});
            },
            child: NotificationsList(
              notifications: notifications,
              onNotificationTap: (notification) async {
                if (!notification.read) {
                  await DatabaseService.markNotificationAsRead(notification.id);
                  // Forcer le rebuild du FutureBuilder
                  setState(() {});
                }
              },
            ),
          );
        },
      ),
    );
  }
}
