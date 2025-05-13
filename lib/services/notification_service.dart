import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Función para guardar una notificación
  Future<void> saveNotification(NotificationModel notification) async {
    try {
      print("📌 Guardando notificación en Firestore...");
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

  /// Marca una notificación como leída usando el ID del documento de Firebase
  Future<void> markNotificationAsRead(String documentId) async {
    try {
      // 🔎 Actualizar el campo "isRead" del documento identificado por el ID
      await _firebaseFirestore
          .collection('notifications')
          .doc(documentId)
          .update({'isRead': true});
    } catch (e) {
      print('Error al actualizar la notificación: $e');
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

  Future<DocumentSnapshot?> getNotificationDocByRequestId(
    String requestId,
  ) async {
    try {
      final querySnapshot =
          await _firebaseFirestore
              .collection('notifications')
              .where('requestId', isEqualTo: requestId)
              .limit(1) // 👈 Limitamos a 1 para optimización
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
    } catch (e) {
      print("Error al obtener notificación: $e");
    }
    return null;
  }

  Future<String?> findNotificationByRequestIdAndType(
    String requestId,
    String tipo,
  ) async {
    try {
      final querySnapshot =
          await _firebaseFirestore
              .collection('notifications')
              .where('requestId', isEqualTo: requestId)
              .where('tipo', isEqualTo: tipo)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Error buscando notificación: $e');
      return null;
    }
  }
}
