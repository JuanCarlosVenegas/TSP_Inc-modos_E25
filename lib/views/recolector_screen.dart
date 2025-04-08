import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../viewmodels/recolector_viewmodel.dart';
import '../models/recoleccion_model.dart';

class PendingRequestsScreen extends StatelessWidget {
  final String collectorId;
  const PendingRequestsScreen({super.key, required this.collectorId});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PendingRequestsViewModel(collectorId: collectorId)..loadPendingRequests(),
      child: Consumer<PendingRequestsViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading || vm.initialPosition == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            body: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: vm.initialPosition!,
                    zoom: 14,
                  ),
                  markers: vm.markers,
                  onMapCreated: vm.setMapController,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
                  bottom: 150,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: "zoom_in",
                        onPressed: vm.zoomIn,
                        mini: true,
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "zoom_out",
                        onPressed: vm.zoomOut,
                        mini: true,
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.3,
                  minChildSize: 0.2,
                  maxChildSize: 0.85,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              "Solicitudes de recolección",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: vm.pendingRequests.length,
                              itemBuilder: (context, index) {
                                final request = vm.pendingRequests[index];
                                return _buildRequestCard(request, vm);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.green,
                ),
                BottomNavigationBar(
                  backgroundColor: Colors.white,
                  selectedItemColor: Colors.green,
                  unselectedItemColor: Colors.black54,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.view_list),
                      label: 'Recolector',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.logout),
                      label: 'Cerrar sesión',
                    ),
                  ],
                  onTap: (index) async {
                    if (index == 0) {
                      debugPrint("Navegar a pantalla de recolector");
                    } else if (index == 1) {
                      vm.logout(context);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(PickupRequest request, PendingRequestsViewModel vm) {
    return FutureBuilder<String>(
      future: vm.getAddressFromCoordinates(request.location.latitude, request.location.longitude),
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
          onTap: () => vm.selectRequest(request.requestId),
          child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10),
          color: const Color(0xFFE8F5E9),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Datos de la solicitud
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📍 $address",  // Mostrar la dirección
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                       /// 💡 Aquí agregamos la distancia
                      if (request.distance != null)
                        Text(
                          "📏 Distancia: ${vm.formatDistance(request.distance)}",
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
                      if (request.status == 'pendiente')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await vm.acceptRequest(request);
                            },
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
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: const Text(
                                "En recolección",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.notifications_active_outlined),
                              color: Colors.grey[800],
                              tooltip: 'Enviar notificación',
                              onPressed: () {
                                // Aquí se implementará la notificación más adelante
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
        ));
      },
    );
  }

}

