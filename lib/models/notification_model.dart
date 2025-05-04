import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String userId;
  final String message;
  final Timestamp timestamp;
  final bool isRead;
  final String requestId; // ID de la solicitud
  final String tipo; // Nuevo campo para el tipo de notificación (ej. "recolector_llego", "basura_desechada")

  NotificationModel({
    required this.userId,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.requestId,
    required this.tipo, // Se pasa el tipo de notificación
  });

  // Convierte el modelo a un mapa JSON para Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
      'requestId': requestId,
      'tipo': tipo, // Incluir el tipo en el JSON
    };
  }

  // Crea una instancia del modelo desde un DocumentSnapshot de Firestore
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NotificationModel(
      userId: data['userId'],
      message: data['message'],
      timestamp: data['timestamp'],
      isRead: data['isRead'],
      requestId: data['requestId'],
      tipo: data['tipo'], // Asignar el tipo
    );
  }
}
