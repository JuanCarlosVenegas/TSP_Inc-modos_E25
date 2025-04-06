import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../viewmodels/pending_request_viewmodel.dart';
import '../models/residuo_model.dart';

class PendingRequestsScreen extends StatelessWidget {
  const PendingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PendingRequestsViewModel()..loadPendingRequests(),
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
                  maxChildSize: 0.6,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: vm.pendingRequests.length,
                        itemBuilder: (context, index) {
                          final request = vm.pendingRequests[index];
                          return _buildRequestCard(request);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
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
                  // Aquí puedes navegar a la pantalla del recolector si ya la tienes
                  debugPrint("Navegar a pantalla de recolector");
                } else if (index == 1) {
                  vm.logout(context); // Ahora se llama correctamente
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(PickupRequest request) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ubicación: ${request.location}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Hora: ${request.time}"),
            Text("Monto: ${request.amount}"),
            Text("Tipo: ${request.wasteType}"),
            Text("Cantidad: ${request.quantity}"),
            Text("Tamaño: ${request.size}"),
          ],
        ),
      ),
    );
  }
}
