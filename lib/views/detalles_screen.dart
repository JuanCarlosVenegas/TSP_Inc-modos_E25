import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WasteDetailsView extends StatefulWidget {
  const WasteDetailsView({super.key});

  @override
  State<WasteDetailsView> createState() => _WasteDetailsViewState();
}

class _WasteDetailsViewState extends State<WasteDetailsView> {
  final TextEditingController quantityController = TextEditingController(text: "5");
  String selectedWasteType = "General";
  String selectedSize = "Mediano";

  final List<String> wasteTypes = ['General', 'Orgánico', 'Reciclable'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("EcoRide"),
        backgroundColor: Colors.green[700],
        leading: const Icon(Icons.directions_car),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(19.4326, -99.1332), // Ciudad de México
                zoom: 15,
              ),
              markers: {
                const Marker(
                  markerId: MarkerId('pickup'),
                  position: LatLng(19.4326, -99.1332),
                ),
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Detalles de la basura", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedWasteType,
                          items: wasteTypes
                              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                              .toList(),
                          onChanged: (value) => setState(() => selectedWasteType = value!),
                          decoration: const InputDecoration(
                            labelText: 'Tipo de residuo',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Cantidad',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Tamaño", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['Pequeño', 'Mediano', 'Grande'].map((size) {
                      return GestureDetector(
                        onTap: () => setState(() => selectedSize = size),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: selectedSize == size ? Colors.green[100] : Colors.grey[200],
                                border: Border.all(
                                  color: selectedSize == size ? Colors.green : Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.photo, size: 40, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(size),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // lógica para añadir otro residuo
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Añadir otro residuo"),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // lógica para continuar
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Continuar"),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Ride'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
