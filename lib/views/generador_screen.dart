import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- IMPORTANTE
import '../viewmodels/generador_viewmodel.dart';
import '../views/login_screen.dart';
import '../widgets/request_pickup_appbar.dart';
import '../widgets/request_pickup_map.dart';
import '../widgets/request_main_form.dart';
import '../widgets/request_waste_form.dart';

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
            appBar: RequestPickupAppBar(userId: userId),
            body: Stack(
              children: [
                Column(
                  children: [
                    vm.isLoading || vm.currentPosition == null
                        ? const Center(child: CircularProgressIndicator())
                        : RequestPickupMap(
                          position: LatLng(
                            vm.currentPosition!.latitude,
                            vm.currentPosition!.longitude,
                          ),
                          onTap: vm.updateLocation,
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
                                  ? RequestWasteForm(vm: vm)
                                  : RequestMainForm(vm: vm),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: Colors.green,
              unselectedItemColor: Colors.black,
              currentIndex: 0,
              onTap: (index) {
                if (index == 1) {
                  vm.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_shipping),
                  label: 'Ride',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.logout),
                  label: 'Salir',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
