import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final String userId;
  List<NotificationModel> notifications = [];

  NotificationViewModel({required this.userId});

  Future<void> loadNotifications() async {
    notifications = await NotificationService().getUserNotifications(userId);
    notifyListeners();
  }

  String formatMessage(NotificationModel notif) {
    return notif.message.replaceAll('XXXXXX', notif.requestId);
  }
}
// import 'package:flutter/material.dart';
// import '../models/notification_model.dart';
// import '../services/notification_service.dart';

// class NotificationCenterViewModel extends ChangeNotifier {
//   final String userId;

//   NotificationCenterViewModel(this.userId) {
//     loadNotifications();
//   }

//   List<NotificationModel> notifications = [];
//   bool isLoading = false;

//   Future<void> loadNotifications() async {
//     isLoading = true;
//     notifyListeners();

//     notifications = await NotificationService().getUserNotifications(userId);
    
//     isLoading = false;
//     notifyListeners();
//   }

//   String timeAgo(DateTime date) {
//     final now = DateTime.now();
//     final diff = now.difference(date);

//     if (diff.inMinutes < 60) return '${diff.inMinutes}m';
//     if (diff.inHours < 24) return '${diff.inHours}h';
//     return '${diff.inDays}d';
//   }
// }
