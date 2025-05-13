import 'package:flutter/material.dart';
import '../models/recoleccion_model.dart';
import '../viewmodels/recolector_viewmodel.dart';

class RequestCard extends StatelessWidget {
  final PickupRequest request;
  final PendingRequestsViewModel viewModel;
  final Function(PickupRequest) onAcceptRequest;

  const RequestCard({
    super.key,
    required this.request,
    required this.viewModel,
    required this.onAcceptRequest,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: viewModel.getAddressFromCoordinates(
        request.location.latitude,
        request.location.longitude,
      ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            color: const Color(0xFFE8F5E9),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "📍 $address",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (request.distance != null)
                    Text(
                      "📏 Distancia: ${viewModel.formatDistance(request.distance)}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  const SizedBox(height: 6),
                  Text("🕒 Hora: ${request.time}"),
                  Text("♻️ Tipo: ${request.wasteType}"),
                  Text("🔢 Cantidad: ${request.quantity}"),
                  Text("📦 Tamaño: ${request.size}"),
                  const SizedBox(height: 12),
                  Text(
                    "💰 Monto: ${request.amount}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => onAcceptRequest(request),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("Aceptar solicitud"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF388E3C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
