import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Función para guardar una notificación
  Future<void> saveNotification(NotificationModel notification) async {
    try {
      await _firebaseFirestore
          .collection('notifications')
          .add(notification.toJson());
    } catch (e) {
      print("Error al guardar la notificación: $e");
    }
  }

  /// Obtiene todas las notificaciones de un usuario
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .where('isRead', isEqualTo: false) // CAMBIO AQUÍ
            .get();

    return snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList();
  }

  /// Marca una notificación como leída usando el ID del documento
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firebaseFirestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      rethrow;
    }
  }

  /// Marca todas las notificaciones de un usuario como leídas
  Future<void> markAllAsRead(String userId) async {
    try {
      final querySnapshot =
          await _firebaseFirestore
              .collection('notifications')
              .where('userId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      rethrow;
    }
  }
}
