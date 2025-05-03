import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/custom_map.dart';

class RequestPickupMap extends StatelessWidget {
  final LatLng position;
  final void Function(LatLng) onTap;

  const RequestPickupMap({
    super.key,
    required this.position,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: MapWidget(
        position: position,
        onMapCreated: (_) {},
        onMapTapped: onTap,
      ),
    );
  }
}
