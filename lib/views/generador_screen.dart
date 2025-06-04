import 'package:ecoride/views/historial_screen.dart';
import 'package:ecoride/widgets/cerrarsesion_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../viewmodels/generador_viewmodel.dart';
import '../widgets/custom_map.dart';
import '../widgets/recoleccion_formulario.dart';
import '../widgets/detalles_formulario.dart';
import '../widgets/notificacion_icono.dart';

class RequestPickupScreen extends StatefulWidget {
  final String userId;

  const RequestPickupScreen({super.key, required this.userId});

  @override
  State<RequestPickupScreen> createState() => _RequestPickupScreenState();
}

class _RequestPickupScreenState extends State<RequestPickupScreen> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PickupRequestViewModel(userId: widget.userId),
      child: Consumer<PickupRequestViewModel>(
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
              actions: [NotificationIconWithBadge(userId: widget.userId)],
            ),
            body: IndexedStack(
              index: _selectedIndex,
              children: [
                HistorialScreen(
                  userId: widget.userId,
                  filterBy: 'userId',
                ), // Pantalla de Historial
                // Pantalla principal de Ride
                Column(
                  children: [
                    SizedBox(
                      height: 350,
                      child:
                          vm.isLoading || vm.currentPosition == null
                              ? const Center(child: CircularProgressIndicator())
                              : MapWidget(
                                position: LatLng(
                                  vm.currentPosition!.latitude,
                                  vm.currentPosition!.longitude,
                                ),
                                onMapCreated: (_) {},
                                onMapTapped: (LatLng latLng) {
                                  vm.updateLocation(latLng);
                                },
                              ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child:
                              vm.showWasteForm
                                  ? WasteDetailsForm(viewModel: vm)
                                  : MainRequestForm(viewModel: vm),
                        ),
                      ),
                    ),
                  ],
                ),
                // Pantalla vacía o para logout
                const Center(child: Text('Cerrando sesión...')),
              ],
            ),

            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.green,
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
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Historial',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_shipping),
                  label: 'Ride',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.logout),
                  label: 'Cerrar sesión',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
