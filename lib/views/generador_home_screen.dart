import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../viewmodels/generadorH_viewmodel.dart';
import '../widgets/custom_map.dart';
import '../views/login_screen.dart';

class RequestPickupScreen extends StatelessWidget {
  final String userId;

  const RequestPickupScreen({Key? key, required this.userId}) : super(key: key);

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
                          ? _buildWasteForm(context, vm)
                          : _buildMainForm(context, vm),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              selectedItemColor: Colors.green,
              unselectedItemColor: Colors.black,
              currentIndex: 0,
              onTap: (index) {
                if (index == 1) {
                  final vm = Provider.of<PickupRequestViewModel>(context, listen: false);
                  vm.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                    (route) => false,
                  );
                }
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Ride'),
                BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Salir'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainForm(BuildContext context, PickupRequestViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Solicitar recolección", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        TextField(controller: vm.locationController, decoration: _inputDecoration("Tu ubicación")),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: TextField(controller: vm.timeController, decoration: _inputDecoration("Hora"))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: vm.amountController, decoration: _inputDecoration("Monto"))),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => vm.toggleWasteForm(true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const SizedBox(width: double.infinity, child: Center(child: Text("Agregar detalles"))),
        ),
        const SizedBox(height: 5),
        ElevatedButton(
          onPressed: vm.confirmRequest,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const SizedBox(width: double.infinity, child: Center(child: Text("Confirmar"))),
        ),
      ],
    );
  }

  Widget _buildWasteForm(BuildContext context, PickupRequestViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Detalles de la basura", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: vm.selectedWasteType,
                decoration: _inputDecoration('Tipo de residuo'),
                items: const [
                  DropdownMenuItem(value: 'General', child: Text('General')),
                  DropdownMenuItem(value: 'Orgánico', child: Text('Orgánico')),
                  DropdownMenuItem(value: 'Reciclable', child: Text('Reciclable')),
                ],
                onChanged: (value) => vm.updateWasteType(value!),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Cantidad", style: TextStyle(fontSize: 12)),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Center(child: Text(vm.quantityController.text))),
                        Column(
                          children: [
                            IconButton(icon: const Icon(Icons.arrow_drop_up), onPressed: vm.increaseQuantity),
                            IconButton(icon: const Icon(Icons.arrow_drop_down), onPressed: vm.decreaseQuantity),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text("Tamaño", style: TextStyle(fontWeight: FontWeight.bold)),
        Center(
          child: SizedBox(
            width: 250,
            child: Slider(
              value: vm.sizeValue,
              min: 1,
              max: 3,
              divisions: 2,
              label: vm.sizeLabel,
              onChanged: (value) => vm.updateSize(value.toInt()),
            ),
          ),
        ),
        Center(child: Text("Tamaño seleccionado: ${vm.sizeLabel}")),
        const SizedBox(height: 16),

        ElevatedButton.icon(
          onPressed: vm.selectedImages.length >= 3 ? null : vm.pickImage,
          icon: const Icon(Icons.upload_file),
          label: Text("Subir foto (${vm.selectedImages.length}/3)"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black,
          ),
        ),

        if (vm.selectedImages.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: vm.selectedImages
                .map((file) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
                    ))
                .toList(),
          ),
        ],

        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => vm.toggleWasteForm(false),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const SizedBox(width: double.infinity, child: Center(child: Text("Continuar"))),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(labelText: label, border: const OutlineInputBorder());
  }
}
