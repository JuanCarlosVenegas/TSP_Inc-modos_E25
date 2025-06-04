import 'package:ecoride/models/recoleccion_model.dart'; 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewmodels/historial_viewmodel.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../widgets/historial_card.dart';
import '../services/historial_service.dart';

class HistorialScreen extends StatefulWidget {
  final String userId;
  final String filterBy;

  const HistorialScreen({
    super.key,
    required this.userId,
    required this.filterBy,
  });

  @override
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  late final HistorialViewModel _viewModel;
  late final NotificationViewModel _notificationVM;
  final HistorialService _geoService = HistorialService();

  @override
  void initState() {
    super.initState();
    _viewModel = HistorialViewModel(widget.userId, widget.filterBy);
    _notificationVM = NotificationViewModel(userId: widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _viewModel.getFilteredStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Cargando recolecciones...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Parece que no ha realizado ninguna recolección.'),
            );
          }

          final items = _viewModel.groupByDate(snapshot.data!);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // Fuerza la reconstrucción del stream
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(), // Asegura el deslizamiento aunque esté lleno
              itemCount: items.length,
              itemBuilder: (context, index) {
                final date = items.keys.elementAt(index);
                final requests = items[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        date,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ...requests.map((doc) {
                      return HistorialCard(
                        key: ValueKey(doc.id),
                        pickupRequest: PickupRequest.fromJson(
                          doc.data() as Map<String, dynamic>,
                        ),
                        filterBy: widget.filterBy,
                        geoService: _geoService,
                        viewModel: _notificationVM,
                        historialViewModel: _viewModel,
                      );
                    }),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
