import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recoleccion_model.dart';
import '../services/user_service.dart';

void showDetailsModal(BuildContext context, PickupRequest pickupRequest) {
  final UserService userService = UserService();
  ValueNotifier<int> currentImageIndex = ValueNotifier<int>(0);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(16),
        child: FutureBuilder<List<String>>(
          future: Future.wait([
            userService
                .getUserNameById(pickupRequest.userId ?? '')
                .then((value) => value ?? 'Desconocido'),
            userService
                .getUserNameById(pickupRequest.collectorId ?? '')
                .then((value) => value ?? 'Desconocido'),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Error al cargar datos"));
            }

            final generatorName = snapshot.data?[0] ?? 'Desconocido';
            final collectorName = snapshot.data?[1] ?? 'Desconocido';

            return Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header con el título y botón de cerrar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Detalles de la Recolección',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Color.fromARGB(255, 147, 144, 144)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    /// ID de Firebase
                    _buildInfoRow(Icons.numbers, 'ID de Recolección',
                        pickupRequest.requestId),

                    /// Información de la recolección
                    _buildInfoRow(Icons.person, 'Generador', generatorName),
                    _buildInfoRow(Icons.person_pin, 'Recolector', collectorName),
                    _buildInfoRow(Icons.pending, 'Estado', pickupRequest.status),
                    _buildInfoRow(Icons.shopping_bag, 'Cantidad',
                        '${pickupRequest.quantity} bolsas'),
                    _buildInfoRow(Icons.delete, 'Tipo de basura',
                        pickupRequest.wasteType),
                    _buildInfoRow(Icons.attach_money, 'Monto',
                        pickupRequest.amount),
                    _buildInfoRow(Icons.calendar_today, 'Fecha',
                        DateFormat('dd/MM/yyyy hh:mm a')
                            .format(pickupRequest.createdAt)),
                    const SizedBox(height: 16),

                    /// Carrusel de Imágenes
                    if (pickupRequest.imageUrls.isNotEmpty)
                      Column(
                        children: [
                          SizedBox(
                            height: 250,
                            child: ValueListenableBuilder<int>(
                              valueListenable: currentImageIndex,
                              builder: (context, index, _) {
                                return PageView.builder(
                                  itemCount: pickupRequest.imageUrls.length,
                                  onPageChanged: (index) {
                                    currentImageIndex.value = index;
                                  },
                                  itemBuilder: (context, index) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        pickupRequest.imageUrls[index],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),

                          /// Miniaturas de las imágenes
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: pickupRequest.imageUrls.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    currentImageIndex.value = index;
                                  },
                                  child: ValueListenableBuilder<int>(
                                    valueListenable: currentImageIndex,
                                    builder: (context, selectedIndex, _) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: selectedIndex == index
                                                ? Colors.green
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            pickupRequest.imageUrls[index],
                                            fit: BoxFit.cover,
                                            width: 60,
                                            height: 60,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

Widget _buildInfoRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
