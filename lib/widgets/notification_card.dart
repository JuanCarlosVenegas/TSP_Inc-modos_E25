import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification_model.dart';
import '../viewmodels/notification_viewmodel.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({required this.notification, super.key});

  @override
  Widget build(BuildContext context) {
    final bool isRecolector = notification.tipo == 'recolector_llego';
    final viewModel = Provider.of<NotificationViewModel>(
      context,
      listen: false,
    );
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isRecolector ? Colors.yellow[700] : Colors.green,
          radius: 24,
          child: Icon(
            isRecolector ? Icons.local_shipping : Icons.check_circle,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          isRecolector ? 'Recolector ha llegado' : 'Pedido desechado',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          notification.message.replaceAll('XXXXXX', notification.requestId),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            final viewModel = Provider.of<NotificationViewModel>(
              context,
              listen: false,
            );
            viewModel.markAsReadAndRemove(
              notification.requestId,
              notification.tipo,
            );
          },
        ),
      ),
    );
  }
}
