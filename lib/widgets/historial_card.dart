import 'package:ecoride/models/recoleccion_model.dart';
import 'package:ecoride/services/historial_service.dart';
import 'package:ecoride/viewmodels/notification_viewmodel.dart';
import 'package:ecoride/views/incidente_screen.dart';
import 'package:ecoride/widgets/cancelacion_modal.dart';
import 'package:flutter/material.dart';
import '../widgets/detallesHistorial_modal.dart';

class HistorialCard extends StatelessWidget {
  final PickupRequest pickupRequest;
  final String filterBy;
  final HistorialService geoService;
  final NotificationViewModel viewModel; // Aquí agregas el ViewModel

  const HistorialCard({
    Key? key,
    required this.pickupRequest,
    required this.filterBy,
    required this.geoService,
    required this.viewModel, // Recibiendo el ViewModel
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDetailsModal(context, pickupRequest),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estado
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(pickupRequest.status),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      pickupRequest.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    pickupRequest.time,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              // Información
              Expanded(
                child: FutureBuilder<String>(
                  future: geoService.getAddressFromCoordinates(
                    pickupRequest.location.latitude,
                    pickupRequest.location.longitude,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Cargando dirección...");
                    }
                    if (snapshot.hasError) {
                      return const Text("Dirección no disponible");
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Dirección
                        Text(
                          snapshot.data ?? 'Dirección no disponible',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),

                        /// Información adicional
                        Text(
                          '${pickupRequest.quantity} bolsas - ${pickupRequest.wasteType}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          pickupRequest.amount,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 15),

                        /// ID de la Recolección (Firebase)
                        Text(
                          "ID: ${pickupRequest.requestId}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Menú de los tres puntitos
              Container(
                margin: const EdgeInsets.only(left: 5),
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.black,
                    size: 20,
                  ),
                  onSelected: (value) async {
                    if (value == 'Cancelar') {
                      await ConfirmCancellation.show(
                        context,
                        pickupRequest,
                        filterBy,
                        pickupRequest.userId,
                      );
                    } else if (value == 'Finalizar') {
                      // Lógica para finalizar
                      await viewModel.sendWasteDisposedNotification(
                        pickupRequest,
                      );
                    } else if (value == 'Reportar Incidencia') {
                      // Navegación a ReportIncidentScreen
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return ReportIncidentDialog(
                            pickupRequest:
                                pickupRequest, // Se envía el objeto completo
                          );
                        },
                      );
                    } else if (value == 'Notificar Llegada') {
                      // Usamos el viewModel directamente
                      await viewModel.sendCollectorArrivalNotification(
                        pickupRequest,
                      );
                    }
                  },
                  itemBuilder: (context) {
                    if (filterBy == 'userId') {
                      return [
                        const PopupMenuItem(
                          value: 'Cancelar',
                          child: Text('❌​ Cancelar'),
                        ),
                        const PopupMenuItem(
                          value: 'Reportar Incidencia',
                          child: Text('⚠️​ Reportar Incidencia'),
                        ),
                      ];
                    } else if (filterBy == 'collectorId') {
                      return [
                        const PopupMenuItem(
                          value: 'Finalizar',
                          child: Text('✅​ Finalizar'),
                        ),
                        const PopupMenuItem(
                          value: 'Notificar Llegada',
                          child: Text('🔔​​ Notificar Llegada'),
                        ),
                        const PopupMenuItem(
                          value: 'Cancelar',
                          child: Text('❌​ Cancelar'),
                        ),
                        const PopupMenuItem(
                          value: 'Reportar Incidencia',
                          child: Text('⚠️​ Reportar Incidencia'),
                        ),
                      ];
                    }
                    return [];
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return Colors.orange;
      case 'Cancelado':
        return Colors.red;
      case 'Finalizado':
        return Colors.green;
      case 'Recolección':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
