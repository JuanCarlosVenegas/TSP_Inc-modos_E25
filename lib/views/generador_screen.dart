import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../viewmodels/generador_viewmodel.dart';
import '../widgets/custom_map.dart';
import '../widgets/recoleccion_formulario.dart';
import '../widgets/detalles_formulario.dart';
import '../widgets/notificacion_icono.dart';

class RequestPickupScreen extends StatelessWidget {
  final String userId;

  const RequestPickupScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PickupRequestViewModel(userId: userId),
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
              actions: [
                NotificationIconWithBadge(userId: userId),
              ],
            ),
            body: Column(
              children: [
                SizedBox(
                  height: 350,
                  child: vm.isLoading || vm.currentPosition == null
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
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: vm.showWasteForm
                          ? WasteDetailsForm(viewModel: vm)
                          : MainRequestForm(viewModel: vm),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              selectedItemColor: Colors.green,
              onTap: (index) {
                if (index == 1) {
                  vm.logout(context);
                }
              },
              items: const [
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
