import 'package:flutter/material.dart';
import 'package:houbago/houbago/database/database_service.dart';
import 'package:houbago/houbago/models/notification.dart';
import 'package:houbago/houbago/theme/houbago_theme.dart';

class NotificationList extends StatelessWidget {
  final List<NotificationModel> notifications;

  const NotificationList({
    super.key,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: notification.type.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              notification.type.icon,
              color: notification.type.color,
            ),
          ),
          title: Text(
            notification.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(notification.message),
          trailing: notification.read
              ? null
              : Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: HoubagoTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
          onTap: () {
            DatabaseService.markNotificationAsRead(notification.id);
          },
        );
      },
    );
  }
}
