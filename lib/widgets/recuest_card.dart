// widgets/request_card.dart
import 'package:flutter/material.dart';
import '../models/recoleccion_model.dart';
import '../viewmodels/recolector_viewmodel.dart';

class RequestCard extends StatelessWidget {
  final PickupRequest request;
  final PendingRequestsViewModel viewModel;

  const RequestCard({super.key, required this.request, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: viewModel.getAddressFromCoordinates(request.location.latitude, request.location.longitude),
      builder: (context, snapshot) {
        String address = 'Cargando dirección...';
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            address = 'Error al obtener dirección';
          } else {
            address = snapshot.data ?? 'Dirección no encontrada';
          }
        }

        return GestureDetector(
          onTap: () => viewModel.selectRequest(request.requestId),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            color: request.status == 'en recolección'
              ? const Color(0xFFFFF9C4)
              : const Color(0xFFE8F5E9),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Datos
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("📍 $address", style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (request.distance != null)
                          Text("📏 Distancia: ${viewModel.formatDistance(request.distance)}", style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text("🕒 Hora: ${request.time}"),
                        Text("♻️ Tipo: ${request.wasteType}"),
                        Text("🔢 Cantidad: ${request.quantity}"),
                        Text("📦 Tamaño: ${request.size}"),
                        const SizedBox(height: 12),
                        Text("💰 Monto: ${request.amount}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                        const SizedBox(height: 12),
                        if (request.status == 'pendiente')
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => viewModel.acceptRequest(request),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text("Aceptar solicitud"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF388E3C),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                child: const Text(
                                  "En recolección",
                                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.notifications_active_outlined),
                                color: Colors.grey[800],
                                tooltip: 'Enviar notificación',
                                onPressed: () {
                                  viewModel.sendNotification(
                                    userId: request.userId,
                                    requestId: request.requestId,
                                    tipo: 'recolector_llego',
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Notificación enviada exitosamente')),
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Imágenes
                  if (request.imageUrls.isNotEmpty)
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: request.imageUrls.map((url) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                url,
                                height: 80,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
