import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../widgets/notification_card.dart';

class NotificationCenterScreen extends StatelessWidget {
  final String userId;
  const NotificationCenterScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationViewModel(userId: userId)..loadNotifications(),
      child: Consumer<NotificationViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: Row(
                children: [
                  Image.asset('assets/locoEcoRide.png', height: 30),
                  const SizedBox(width: 10),
                  const Text("EcoRide", style: TextStyle(color: Colors.white)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Notificaciones",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: vm.notifications.isEmpty
                        ? const Center(child: Text("No hay notificaciones"))
                        : ListView.builder(
                            itemCount: vm.notifications.length,
                            itemBuilder: (context, index) {
                              final notif = vm.notifications[index];
                              return NotificationCard(
                                notification: notif,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
