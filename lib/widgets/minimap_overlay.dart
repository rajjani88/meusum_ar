import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../controllers/place_controller.dart';

class MinimapOverlay extends StatelessWidget {
  const MinimapOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlaceController>();

    return Obx(() {
      // Rebuild when observable changes. We must access them here for Obx to register.
      // ignore: unused_local_variable
      final userLat = controller.userLat.value;
      // ignore: unused_local_variable
      final userLng = controller.userLng.value;
      // ignore: unused_local_variable
      final selectedPlace = controller.selectedPlace.value;
      // We also depend on the list of places potentially changing
      // ignore: unused_local_variable
      final placesLength = controller.places.length;

      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: CustomPaint(
            // We pass the controller, which holds the data.
            // The CustomPaint will be rebuilt because Obx rebuilds this entire subtree
            // whenever the values accessed above change.
            painter: MinimapPainter(controller),
            size: const Size(120, 120),
          ),
        ),
      );
    });
  }
}

class MinimapPainter extends CustomPainter {
  final PlaceController controller;

  MinimapPainter(this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    // ... paint logic remains the same ...
    // Note: Since we are creating a NEW MinimapPainter on every Obx rebuild,
    // the paint method will use the LATEST values from the controller.

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background
    final bgPaint = Paint()..color = Colors.grey.shade100;
    canvas.drawCircle(center, radius, bgPaint);

    // User is always at the center
    final userPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, userPaint);

    // View cone (Rotate based on compass heading)
    // Compass 0 is North (Up). In canvas, -pi/2 is Up.
    // We want the map to stay fixed (North up) and the user cone to rotate?
    // OR Map rotates and user stays fixed?
    // Request was: "move user focus as it moves phone".
    // Usually minimaps are North-Up and user arrow rotates.

    // Convert degrees to radians
    // 0 degrees (North) -> -pi/2 (Up in Canvas)
    // 90 degrees (East) -> 0 (Right in Canvas)
    // Formula: (heading - 90) * (pi / 180)

    final heading = controller.userHeading.value;
    final angleInRadians = (heading - 90) * (math.pi / 180);

    final conePaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final conePath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(
        center.dx + 40 * math.cos(angleInRadians - 0.4),
        center.dy + 40 * math.sin(angleInRadians - 0.4),
      )
      ..quadraticBezierTo(
        center.dx + 50 * math.cos(angleInRadians),
        center.dy + 50 * math.sin(angleInRadians),
        center.dx + 40 * math.cos(angleInRadians + 0.4),
        center.dy + 40 * math.sin(angleInRadians + 0.4),
      )
      ..close();

    canvas.drawPath(conePath, conePaint);

    // Draw places using relative positions
    final scale = 5.0; // 1 meter = 5 pixels (adjust based on arena size)

    for (final place in controller.places) {
      final isSelected = controller.selectedPlace.value?.id == place.id;

      // Calculate relative position from place.position (x, y, z)
      // AR Coordinate system: -Z is forward, +X is right
      // Map Coordinate system: -Y is forward (up), +X is right

      final double dx = place.position.x * scale;
      final double dy = place.position.z * scale; // Map Z to Y

      // Distance check
      final distSquared = dx * dx + dy * dy;
      if (distSquared < (radius - 5) * (radius - 5)) {
        final placePaint = Paint()
          ..color = isSelected ? Colors.red : Colors.orange
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(center.dx + dx, center.dy + dy),
          isSelected ? 6 : 4,
          placePaint,
        );
      } else {
        // Draw indicator on edge if out of bounds
        final angle = math.atan2(dy, dx);
        final edgeX = center.dx + (radius - 5) * math.cos(angle);
        final edgeY = center.dy + (radius - 5) * math.sin(angle);

        final edgePaint = Paint()
          ..color = isSelected
              ? Colors.red
              : Colors.orange.withValues(alpha: 0.5)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(edgeX, edgeY), 3, edgePaint);
      }
    }
  }

  @override
  bool shouldRepaint(MinimapPainter oldDelegate) => true; // simplistic repaint
}
