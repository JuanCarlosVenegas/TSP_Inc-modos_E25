import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecoride/models/recoleccion_model.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final String userId;
  List<NotificationModel> notifications = [];
  final NotificationService _notificationService = NotificationService();

  NotificationViewModel({required this.userId});

  /// 🔄 Carga las notificaciones del usuario desde Firestore
  Future<void> loadNotifications() async {
    notifications = await _notificationService.getUserNotifications(userId);

    // Filtrar solo las no leídas
    notifications = notifications.where((n) => !n.isRead).toList();

    notifyListeners();
  }

  Future<void> markAsRead(String requestId) async {
    try {
      await _notificationService.markNotificationAsRead(requestId);
      notifyListeners(); // Notificar a los widgets que dependen de este ViewModel
    } catch (e) {
      print('Error al actualizar la notificación: $e');
    }
  }

  /// ❌ Remueve la notificación de la lista en memoria
  void removeNotificationFromList(String requestId, String tipo) {
    notifications.removeWhere(
      (n) => n.requestId == requestId && n.tipo == tipo,
    );
    notifyListeners();
  }

  // Método en el ViewModel para buscar por requestId y tipo, marcar como leída y eliminar de la lista
  Future<void> markAsReadAndRemove(String requestId, String tipo) async {
    try {
      // 🔍 Buscar el ID en Firebase
      final documentId = await _notificationService
          .findNotificationByRequestIdAndType(requestId, tipo);

      if (documentId != null) {
        // ✅ Marcar como leída en Firebase
        await _notificationService.markNotificationAsRead(documentId);

        // ✅ Eliminar de la lista local
        notifications.removeWhere(
          (n) => n.requestId == requestId && n.tipo == tipo,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error al actualizar la notificación: $e');
    }
  }

  Future<void> sendNotification({
    required String userId,
    required String requestId,
    required String tipo,
    required String hora,
  }) async {
    // Crear el mensaje según el tipo de notificación
    String message;
    if (tipo == 'recolector_llego') {
      message =
          "El recolector de tu pedido solicitado a las ${hora} ha llegado a tu dirección de recolección\n ¡Sal a darle tus desechos!";
    } else if (tipo == 'basura_desechada') {
      message = "Su pedido ${requestId} ha sido desechado correctamente";
    } else {
      message = "Notificación de recolección de basura.";
    }

    // Crear el modelo de notificación
    final notification = NotificationModel(
      userId: userId,
      message: message,
      timestamp: Timestamp.now(),
      isRead: false,
      requestId: requestId,
      tipo: tipo,
    );

    // Guardar la notificación
    await _notificationService.saveNotification(notification);

    // Notificar a los listeners (si es necesario)
    notifyListeners();
  }

  // Método para mostrar mensajes tipo Snackbar
void _showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ),
  );
}

// Método para enviar la notificación de basura desechada
Future<void> sendWasteDisposedNotification(
    BuildContext context, PickupRequest request) async {
  try {
    await sendNotification(
      userId: request.userId,
      requestId: request.requestId,
      tipo: 'basura_desechada',
      hora: request.time,
    );

    await FirebaseFirestore.instance
        .collection('pickup_requests')
        .doc(request.requestId)
        .update({
          'pedidoDesechadoNotificado': true,
          'status': 'Finalizado',
        });

    print('✅ Notificación de basura desechada enviada exitosamente.');
    _showSnackbar(context, 'Notificación de basura desechada enviada.');
  } catch (e) {
    print('❌ Error al enviar notificación de basura desechada: $e');
    _showSnackbar(context, 'Error al enviar la notificación.');
  }
}

// Método para enviar la notificación de llegada del recolector
Future<void> sendCollectorArrivalNotification(
    BuildContext context, PickupRequest request) async {
  print("⏳ Método sendCollectorArrivalNotification llamado.");
  try {
    await sendNotification(
      userId: request.userId,
      requestId: request.requestId,
      tipo: 'recolector_llego',
      hora: request.time,
    );

    await FirebaseFirestore.instance
        .collection('pickup_requests')
        .doc(request.requestId)
        .update({'recolectorLlegoNotificado': true});

    print('✅ Notificación de llegada del recolector enviada exitosamente.');
    _showSnackbar(context, 'Notificación de llegada al domicilio enviada.');
  } catch (e) {
    print('❌ Error al enviar notificación de llegada del recolector: $e');
    _showSnackbar(context, 'Error al enviar la notificación.');
  }
}

}
