import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String userId; // ID del usuario que recibe la notificación
  final String message; // El mensaje de la notificación
  final Timestamp timestamp; // La hora en que se envió la notificación
  final bool isRead; // Indica si la notificación ha sido leída

  // Constructor
  NotificationModel({
    required this.userId,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });

  // Método para convertir el modelo a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  // Método para convertir un documento Firestore a un modelo NotificationModel
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return NotificationModel(
      userId: data['userId'],
      message: data['message'],
      timestamp: data['timestamp'],
      isRead: data['isRead'],
    );
  }
}
