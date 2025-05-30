import 'package:ecoride/models/recoleccion_model.dart';
import 'package:ecoride/services/calificacion_service.dart';
import 'package:ecoride/services/chat_service.dart';
import 'package:ecoride/services/historial_service.dart';
import 'package:ecoride/viewmodels/notification_viewmodel.dart';
import 'package:ecoride/views/chat_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/cancelacion_modal.dart';
import '../widgets/detallesHistorial_modal.dart';
import '../views/calificacion_screen.dart';
import '../views/incidente_screen.dart'; // Importa el archivo del diálogo de incidencia
import '../services/user_service.dart';
import 'package:intl/intl.dart';

class HistorialCard extends StatefulWidget {
  final PickupRequest pickupRequest;
  final String filterBy;
  final HistorialService geoService;
  final NotificationViewModel viewModel;

  const HistorialCard({
    super.key,
    required this.pickupRequest,
    required this.filterBy,
    required this.geoService,
    required this.viewModel,
  });

  @override
  _HistorialCardState createState() => _HistorialCardState();
}

class _HistorialCardState extends State<HistorialCard> {
  late PickupRequest _request;
  late UserService _userService;
  late RatingService _califService;

  @override
  void initState() {
    super.initState();
    _request = widget.pickupRequest;
    _userService = UserService();
    _califService = RatingService();
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ID: ${_request.requestId}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  161,
                                  156,
                                  156,
                                ),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    4,
                                  ), // Más cuadrado
                                ),
                              ),
                              onPressed: () {
                                final currentUserId =
                                    widget.filterBy == 'userId'
                                        ? _request.userId
                                        : _request.collectorId ?? '';
                                final otherUserId =
                                    widget.filterBy == 'userId'
                                        ? _request.collectorId ?? ''
                                        : _request.userId;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ChatScreen(
                                          currentUserId: currentUserId,
                                          otherUserId: otherUserId,
                                          requestId: _request.requestId,
                                        ),
                                  ),
                                ).then((_) {
                                  // Al volver del chat, actualizamos el estado para recargar los mensajes no leídos
                                  setState(() {});
                                });
                              },

                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Text("Mensajes"),
                                  FutureBuilder<int>(
                                    future: ChatService()
                                        .getUnreadMessagesCount(
                                          widget.filterBy == 'userId'
                                              ? _request.userId
                                              : _request.collectorId ?? '',
                                          widget.filterBy == 'userId'
                                              ? _request.collectorId ?? ''
                                              : _request.userId,
                                          _request.requestId,
                                        ),
                                    builder: (context, snapshot) {
                                      final count = snapshot.data ?? 0;
                                      if (count == 0) return const SizedBox();

                                      return Positioned(
                                        top: -6,
                                        right: -16,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            count > 9 ? '9+' : '$count',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                    } else if (value == 'Calificar') {
                      String nameToShow = 'Desconocido';
                      String actualUserId = 'Desconocido';
                      String calificadoId = 'Desconocido';

                      if (widget.filterBy == 'userId') {
                        nameToShow =
                            await _userService.getUserNameById(
                              _request.collectorId ?? 'amer',
                            ) ??
                            'Usuario';
                        actualUserId = _request.userId;
                        calificadoId = _request.collectorId ?? 'no asignado';
                      } else {
                        nameToShow =
                            await _userService.getUserNameById(
                              _request.userId,
                            ) ??
                            'Usuario';
                        actualUserId = _request.collectorId ?? 'no asignado';
                        calificadoId = _request.userId;
                      }

                      final alreadyRated = await _califService.hasUserRated(
                        _request.requestId,
                        actualUserId,
                      );

                      if (alreadyRated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ya has calificado este servicio.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Mostrar el formulario de calificación
                      showRatingDialog(
                        context: context,
                        collectorName: nameToShow,
                        requestId: _request.requestId,
                        wasteSummary:
                            '${_request.quantity} bolsas - ${_request.wasteType}',
                        date: DateFormat(
                          'dd/MM/yyyy',
                        ).format(_request.createdAt),
                        time: _request.time,
                        amount: _request.amount,
                        fromUserId: actualUserId,
                        toUserId: calificadoId,
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

                      if (_request.status == 'Finalizado') {
                        items.add(
                          const PopupMenuItem(
                            value: 'Calificar',
                            child: Text('⭐ Calificar Servicio'),
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

                      if (_request.status == 'Finalizado') {
                        items.add(
                          const PopupMenuItem(
                            value: 'Calificar',
                            child: Text('⭐ Calificar Servicio'),
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
