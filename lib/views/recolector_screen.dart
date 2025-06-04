import 'package:ecoride/widgets/cerrarsesion_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../viewmodels/recolector_viewmodel.dart';
import '../widgets/solicitudes_recoleccion.dart';
import 'historial_screen.dart';

class PendingRequestsScreen extends StatefulWidget {
  final String collectorId;

  const PendingRequestsScreen({super.key, required this.collectorId});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) =>
              PendingRequestsViewModel(collectorId: widget.collectorId)
                ..loadPendingRequests(),
      child: Consumer<PendingRequestsViewModel>(
        // Usamos Consumer para acceder al vm
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
            ),
            body: IndexedStack(
              index: _selectedIndex,
              children: [
                HistorialScreen(
                  userId: widget.collectorId,
                  filterBy: 'collectorId',
                ),
                // Aquí iría el contenido de PendingRequests
                PendingRequestsContent(
                  viewModel: vm,
                ), // Usamos el vm para mostrar el contenido
                const Center(child: Text('Cerrando sesión...')),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.green,
              unselectedItemColor: Colors.black54,
              currentIndex: _selectedIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Historial',
                ),
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
                if (index == 2) {
                  showDialog(
                    context: context,
                    builder:
                        (context) => LogoutConfirmationDialog(
                          onConfirm: () => vm.logout(context),
                        ),
                  );
                } else {
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class PendingRequestsContent extends StatelessWidget {
  final PendingRequestsViewModel viewModel;

  const PendingRequestsContent({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.isLoading || viewModel.initialPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: viewModel.initialPosition!,
            zoom: 14,
          ),
          markers: viewModel.markers,
          onMapCreated: viewModel.setMapController,
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
                onPressed: viewModel.zoomIn,
                mini: true,
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: "zoom_out",
                onPressed: viewModel.zoomOut,
                mini: true,
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
        DraggableRequestsSheet(viewModel: viewModel),
      ],
    );
  }
}
