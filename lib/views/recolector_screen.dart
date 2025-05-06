// views/pending_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../viewmodels/recolector_viewmodel.dart';
import '../widgets/solicitudes_recoleccion.dart';

class PendingRequestsScreen extends StatelessWidget {
  final String collectorId;

  const PendingRequestsScreen({super.key, required this.collectorId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) =>
              PendingRequestsViewModel(collectorId: collectorId)
                ..loadPendingRequests(),
      child: Consumer<PendingRequestsViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading || vm.initialPosition == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

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
            ),
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
                DraggableRequestsSheet(viewModel: vm),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.green,
              unselectedItemColor: Colors.black54,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.view_list),
                  label: 'Recolecciones',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.logout),
                  label: 'Cerrar sesión',
                ),
              ],
              onTap: (index) {
                if (index == 1) vm.logout(context);
              },
            ),
          );
        },
      ),
    );
  }
}
