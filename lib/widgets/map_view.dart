import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../controllers/place_controller.dart';

class MapViewWidget extends StatelessWidget {
  const MapViewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlaceController>();

    return Container(
      color: Colors.grey[200],
      child: Stack(
        children: [
          // Simplified map representation
          CustomPaint(painter: MapPainter(controller), size: Size.infinite),

          // Map controls
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  onPressed: () {},
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  onPressed: () {},
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Legend
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('You', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Target', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final PlaceController controller;

  MapPainter(this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    for (int i = 0; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        gridPaint,
      );
    }
    for (int i = 0; i < size.height; i += 40) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        gridPaint,
      );
    }

    // User position (center-bottom)
    final userX = size.width / 2;
    final userY = size.height * 0.7;

    final userPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(userX, userY), 8, userPaint);

    // User direction indicator
    final directionPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;
    final angleInDegrees = controller.getDirectionAngle();
    final angleInRadians = angleInDegrees * math.pi / 180;
    final endX = userX + 20 * math.cos(angleInRadians);
    final endY = userY + 20 * math.sin(angleInRadians);
    canvas.drawLine(Offset(userX, userY), Offset(endX, endY), directionPaint);

    // Draw places
    for (final place in controller.places) {
      final isSelected = controller.selectedPlace.value?.id == place.id;

      // Normalize place coordinates to screen size (pseudo-mapping)
      final placeX = (place.longitude + 74.0065) * (size.width / 0.002);
      final placeY = (place.latitude - 40.7125) * (size.height / 0.002);

      final placePaint = Paint()
        ..color = isSelected ? Colors.red : Colors.orange
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(placeX, placeY),
        isSelected ? 10 : 6,
        placePaint,
      );

      // Draw line to selected place
      if (isSelected) {
        final linePaint = Paint()
          ..color = Colors.red.withOpacity(0.3)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(userX, userY),
          Offset(placeX, placeY),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) => true;
}
