import 'package:ecoride/models/recoleccion_model.dart';
import 'package:ecoride/services/historial_service.dart';
import 'package:ecoride/viewmodels/notification_viewmodel.dart';
import 'package:flutter/material.dart';
import '../widgets/cancelacion_modal.dart';
import '../widgets/detallesHistorial_modal.dart';
import '../views/incidente_view.dart'; // Importa el archivo del diálogo de incidencia

class HistorialCard extends StatefulWidget {
  final PickupRequest pickupRequest;
  final String filterBy;
  final HistorialService geoService;
  final NotificationViewModel viewModel;

  const HistorialCard({
    Key? key,
    required this.pickupRequest,
    required this.filterBy,
    required this.geoService,
    required this.viewModel,
  }) : super(key: key);

  @override
  _HistorialCardState createState() => _HistorialCardState();
}

class _HistorialCardState extends State<HistorialCard> {
  late PickupRequest _request;

  @override
  void initState() {
    super.initState();
    _request = widget.pickupRequest;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDetailsModal(context, _request),
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
                      color: _getStatusColor(_request.status),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      _request.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _request.time,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              // Información
              Expanded(
                child: FutureBuilder<String>(
                  future: widget.geoService.getAddressFromCoordinates(
                    _request.location.latitude,
                    _request.location.longitude,
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
                        Text(
                          snapshot.data ?? 'Dirección no disponible',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${_request.quantity} bolsas - ${_request.wasteType}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _request.amount,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "ID: ${_request.requestId}",
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
                        _request,
                        widget.filterBy,
                        _request.userId,
                      );
                    } else if (value == 'Finalizar' &&
                        !_request.pedidoDesechadoNotificado) {
                      await widget.viewModel.sendWasteDisposedNotification(
                        context,
                        _request,
                      );

                      // Actualización local del estado para reflejar el cambio
                      setState(() {
                        _request = _request.copyWith(
                          pedidoDesechadoNotificado: true,
                          status: "Finalizado",
                        );
                      });
                    } else if (value == 'Notificar Llegada' &&
                        !_request.recolectorLlegoNotificado) {
                      await widget.viewModel.sendCollectorArrivalNotification(
                        context,
                        _request,
                      );

                      // Actualización local del estado para reflejar el cambio
                      setState(() {
                        _request = _request.copyWith(
                          recolectorLlegoNotificado: true,
                        );
                      });
                    } else if (value == 'Reportar Incidencia') {
                      // Mostrar el diálogo de reporte de incidencia
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ReportIncidentDialog(pickupRequest: _request);
                        },
                      );
                    }
                  },
                  itemBuilder: (context) {
                    List<PopupMenuEntry<String>> items = [];

                    // Opción para 'userId'
                    if (widget.filterBy == 'userId') {
                      items.add(
                        const PopupMenuItem(
                          value: 'Reportar Incidencia',
                          child: Text('⚠️​ Reportar Incidencia'),
                        ),
                      );

                      // Verificar si está en estado "Pendiente" y agregar opción de "Cancelar"
                      if (_request.status == 'Pendiente') {
                        items.add(
                          const PopupMenuItem(
                            value: 'Cancelar',
                            child: Text('❌​ Cancelar'),
                          ),
                        );
                      }
                    }

                    // Opciones para 'collectorId'
                    if (widget.filterBy == 'collectorId') {
                      items.add(
                        PopupMenuItem(
                          value: 'Finalizar',
                          enabled: !_request.pedidoDesechadoNotificado,
                          child: const Text('✅​ Finalizar'),
                        ),
                      );
                      items.add(
                        PopupMenuItem(
                          value: 'Notificar Llegada',
                          enabled: !_request.recolectorLlegoNotificado,
                          child: const Text('🔔​​ Notificar Llegada'),
                        ),
                      );
                      items.add(
                        const PopupMenuItem(
                          value: 'Reportar Incidencia',
                          child: Text('⚠️​ Reportar Incidencia'),
                        ),
                      );

                      // Verificar si está en estado "Recolección" y agregar opción de "Cancelar"
                      if (_request.status == 'Recolección') {
                        items.add(
                          const PopupMenuItem(
                            value: 'Cancelar',
                            child: Text('❌​ Cancelar'),
                          ),
                        );
                      }
                    }

                    return items;
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
