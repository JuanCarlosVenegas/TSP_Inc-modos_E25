import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../viewmodels/generador_viewmodel.dart';
import '../widgets/custom_map.dart';
import '../views/login_screen.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';


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
        TextField(
          controller: vm.locationController,
          decoration: _inputDecoration("Tu ubicación"),
          focusNode: vm.locationFocusNode,
          onSubmitted: (value) {
            vm.updatePositionFromAddress(value);
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () async {
                  TimeOfDay? selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (BuildContext context, Widget? child) {
                      // Aplicar un tema personalizado para cambiar el color del reloj
                      return Theme(
                        data: ThemeData.light().copyWith(
                          primaryColor: Colors.green, // Cambiar a verde
                          colorScheme: ColorScheme.light(primary: Colors.green),    // Aseguramos que los iconos también sean verdes
                          buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (selectedTime != null) {
                    final formattedTime = selectedTime.format(context);
                    vm.timeController.text = formattedTime;
                    vm.notifyListeners();
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Hora",
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    vm.timeController.text.isEmpty
                        ? 'Seleccionar hora'
                        : vm.timeController.text,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: TextField(
              controller: vm.amountController,
              decoration: _inputDecoration("Monto"),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                MoneyInputFormatter(
                  leadingSymbol: '\$',
                  useSymbolPadding: true,
                  thousandSeparator: ThousandSeparator.Comma, // Opcional, puedes usar .dot
                  mantissaLength: 2, // Número de decimales
                ),
              ],
            )),
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
            Container(
              width: 110,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 20),
                    onPressed: vm.decreaseQuantity,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        vm.quantityController.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: vm.increaseQuantity,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
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
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.green,     // Línea activa (deslizada)
                inactiveTrackColor: Colors.green[100], // Línea inactiva (sin deslizar)
                thumbColor: Colors.green,           // El "círculo" que se arrastra
                overlayColor: Colors.green.withOpacity(0.2), // Color cuando haces tap o drag
                valueIndicatorColor: Colors.green,  // Color del indicador flotante (label)
              ),
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



