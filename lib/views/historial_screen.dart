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
    Key? key,
    required this.userId,
    required this.filterBy,
  }) : super(key: key);

  @override
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  late final HistorialViewModel _viewModel;
  late final NotificationViewModel _notificationVM; // ✅ Ahora es late
  final HistorialService _geoService = HistorialService();

  @override
  void initState() {
    super.initState();
    _viewModel = HistorialViewModel(widget.userId, widget.filterBy);
    _notificationVM = NotificationViewModel(userId: widget.userId);
  }

  /// Método para confirmar la cancelación de una recolección
  

void _confirmCancellation(BuildContext context, PickupRequest pickupRequest) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              Text(
                '¿Seguro que quieres cancelar la recolección?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),

              // Detalles de la recolección
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pedido: ${pickupRequest.requestId}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    FutureBuilder<String>(
                      future: HistorialService().getAddressFromCoordinates(
                        pickupRequest.location.latitude,
                        pickupRequest.location.longitude,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text("Cargando dirección...");
                        }
                        if (snapshot.hasError) {
                          return const Text("Dirección no disponible");
                        }
                        return Text(
                          "Calle: ${snapshot.data ?? 'No disponible'}",
                        );
                      },
                    ),
                    const SizedBox(height: 5),
                    Text("💲 ${pickupRequest.amount}"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Botones de confirmación
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Sí',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  if (confirm == true) {
    // Llamar al método de cancelación en el ViewModel
    //await HistorialViewModel().cancelPickup(pickupRequest);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recolección cancelada exitosamente')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _viewModel.getFilteredStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Parece que no ha realizado ninguna recolección.'));
          }

          final items = _viewModel.groupByDate(snapshot.data!);

          return ListView.builder(
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
                  ...requests.map((pickupRequest) {
                    return HistorialCard(
                      pickupRequest: pickupRequest,
                      filterBy: widget.filterBy,
                      geoService: _geoService,
                      viewModel: _notificationVM,
                    );
                  }).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
