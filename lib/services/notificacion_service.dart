import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Método para marcar la notificación como leída
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      // Accedemos al documento de la notificación y actualizamos el campo 'isRead'
      final notificationRef = _firebaseFirestore
          .collection('notifications')
          .doc(notificationId);
      await notificationRef.update({'isRead': true});
      //  print("Notificación marcada como leída.");
    } catch (e) {
      //  print("Error al marcar la notificación como leída: $e");
      rethrow;
    }
  }
}
