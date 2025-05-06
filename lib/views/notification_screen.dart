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
                  const Text("EcoRide"),
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
                  const Text("Notificaciones", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                                onClose: () {
                                  // Aquí puedes marcar como leída o eliminarla
                                },
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
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../viewmodels/notification_viewmodel.dart';

// class NotificationCenterView extends StatelessWidget {
//   final String userId;

//   const NotificationCenterView({Key? key, required this.userId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => NotificationCenterViewModel(userId),
//       child: Consumer<NotificationCenterViewModel>(
//         builder: (context, vm, _) {
//           return Scaffold(
//             appBar: AppBar(
//               backgroundColor: Colors.green,
//               title: Row(
//                 children: [
//                   Image.asset('assets/locoEcoRide.png', height: 30),
//                   const SizedBox(width: 10),
//                   const Text(
//                     "EcoRide",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ],
//               ),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.notifications, color: Colors.white),
//                   onPressed: () {}, // Ya estamos en la vista de notificaciones
//                 ),
//               ],
//             ),
//             body: vm.isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : vm.notifications.isEmpty
//                     ? const Center(child: Text("No hay notificaciones"))
//                     : ListView.builder(
//                         itemCount: vm.notifications.length,
//                         itemBuilder: (context, index) {
//                           final notification = vm.notifications[index];
//                           return ListTile(
//                             leading: Icon(
//                               notification.tipo == 'recolector_llego'
//                                   ? Icons.directions_walk
//                                   : Icons.check_circle_outline,
//                             ),
//                             title: Text(
//                               notification.tipo == 'recolector_llego'
//                                   ? 'Recolector ha llegado'
//                                   : 'Basura desechada',
//                             ),
//                             subtitle: Text(notification.message),
//                             trailing: Text(
//                               vm.timeAgo(notification.timestamp.toDate()),
//                               style: const TextStyle(fontSize: 12, color: Colors.grey),
//                             ),
//                           );
//                         },
//                       ),
//           );
//         },
//       ),
//     );
//   }
// }
