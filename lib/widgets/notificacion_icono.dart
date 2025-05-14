import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/notification_view.dart';

class NotificationIconWithBadge extends StatelessWidget {
  final String userId;

  const NotificationIconWithBadge({super.key, required this.userId});

  Stream<int> _unreadNotificationsCountStream() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationCenterScreen(userId: userId),
              ),
            );
          },
        ),
        Positioned(
          right: 6,
          top: 6,
          child: StreamBuilder<int>(
            stream: _unreadNotificationsCountStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == 0) {
                return Container(); // Si no hay datos o el conteo es 0, no se muestra el badge
              }

              final count = snapshot.data ?? 0;

              return Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$count',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
