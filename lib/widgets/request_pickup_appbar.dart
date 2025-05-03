import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequestPickupAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userId; // ID del usuario autenticado

  const RequestPickupAppBar({super.key, required this.userId});

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Notificaciones pendientes",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('notifications')
                          .where('userId', isEqualTo: userId)
                          .where('isRead', isEqualTo: false)
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No hay notificaciones nuevas."));
                        }

                        final notifications = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            final message = notification['message'];
                            final id = notification.id;

                            return Dismissible(
                              key: Key(id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) {
                                FirebaseFirestore.instance
                                    .collection('notifications')
                                    .doc(id)
                                    .update({'isRead': true});
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                color: Colors.green[50],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                child: ListTile(
                                  leading: const Icon(Icons.notifications, color: Colors.green),
                                  title: Text(
                                    message,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.check, color: Colors.green),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('notifications')
                                          .doc(id)
                                          .update({'isRead': true});
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
          onPressed: () => _showNotifications(context),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
