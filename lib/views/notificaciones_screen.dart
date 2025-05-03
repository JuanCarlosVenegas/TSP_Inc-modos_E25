import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notificacion_model.dart';

class NotificationScreen extends StatelessWidget {
  final String
  userId; // El ID del usuario para el que se filtran las notificaciones

  const NotificationScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notificaciones")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('notifications') // Colección de notificaciones
                .where('userId', isEqualTo: userId) // Filtra por el userId
                .orderBy('timestamp', descending: true) // Ordena por fecha
                .snapshots(), // Flujo en tiempo real
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error al cargar las notificaciones"));
          }

          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No tienes nuevas notificaciones"));
          }

          // Convertir los documentos de Firestore a modelos NotificationModel
          final notifications =
              snapshot.data!.docs.map((doc) {
                return NotificationModel.fromFirestore(doc);
              }).toList();

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text(notification.message),
                subtitle: Text(notification.timestamp.toDate().toString()),
                leading: Icon(
                  notification.isRead ? Icons.check : Icons.notifications,
                ),
                onTap: () {
                  // Si la notificación no ha sido leída, marcarla como leída
                  if (!notification.isRead) {
                    _markNotificationAsRead(notification);
                  }
                  // Mostrar la notificación en un BottomSheet
                  _showNotificationBottomSheet(context, notification);
                },
              );
            },
          );
        },
      ),
    );
  }

  // Función para marcar la notificación como leída
  Future<void> _markNotificationAsRead(NotificationModel notification) async {
    final notificationRef = FirebaseFirestore.instance
        .collection('notifications')
        .doc(
          notification.timestamp.toString(),
        ); // Usa el timestamp como identificador único

    await notificationRef.update({'isRead': true});
  }

  // Función para mostrar los detalles de la notificación en un BottomSheet
  void _showNotificationBottomSheet(
    BuildContext context,
    NotificationModel notification,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notificación",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 10),
              Text("Mensaje: ${notification.message}"),
              SizedBox(height: 10),
              Text("Fecha: ${notification.timestamp.toDate()}"),
              SizedBox(height: 10),
              // Puedes agregar más detalles de la notificación aquí
            ],
          ),
        );
      },
    );
  }
}
