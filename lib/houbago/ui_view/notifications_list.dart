import 'package:flutter/material.dart';
import 'package:houbago/houbago/houbago_theme.dart';
import 'package:houbago/houbago/models/notification.dart';
import 'package:intl/intl.dart';

class NotificationsList extends StatelessWidget {
  final List<NotificationModel> notifications;
  final Function(NotificationModel)? onNotificationTap;

  const NotificationsList({
    super.key,
    required this.notifications,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'Aucune notification',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return ListTile(
          onTap: () {
            if (onNotificationTap != null) {
              onNotificationTap!(notification);
            }
          },
          leading: CircleAvatar(
            backgroundColor: notification.read
                ? Colors.grey[200]
                : HoubagoTheme.primary.withOpacity(0.1),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: notification.read
                  ? Colors.grey[400]
                  : HoubagoTheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(notification.createdAt),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.earning:
        return Icons.attach_money;
      case NotificationType.withdrawal:
        return Icons.wallet;
      case NotificationType.affiliation:
        return Icons.people;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }
}
