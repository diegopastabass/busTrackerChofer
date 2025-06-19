import 'package:flutter/material.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onCenterMap;
  final VoidCallback onToggleTracking;
  final bool isTracking;

  const MapControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onCenterMap,
    required this.onToggleTracking,
    required this.isTracking,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'btnCenter',
          onPressed: onCenterMap,
          backgroundColor: Colors.blue[800],
          mini: true,
          child: const Icon(Icons.center_focus_strong),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: 'btnTracking',
          onPressed: onToggleTracking,
          backgroundColor: isTracking ? Colors.blue[800] : Colors.grey,
          mini: true,
          child: Icon(isTracking ? Icons.gps_fixed : Icons.gps_not_fixed),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: 'btnZoomIn',
          onPressed: onZoomIn,
          mini: true,
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: 'btnZoomOut',
          onPressed: onZoomOut,
          mini: true,
          child: const Icon(Icons.remove),
        ),
      ],
    );
  }
}
