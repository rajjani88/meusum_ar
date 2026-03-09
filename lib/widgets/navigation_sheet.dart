import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/place_controller.dart';
import '../models/place_model.dart';

class NavigationSheet extends StatelessWidget {
  final Place place;

  const NavigationSheet({Key? key, required this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlaceController>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(place.icon, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 16),

          // Place Details
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${place.distance.toInt()}m • ${_getEstimatedTime(place.distance)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          // Action Button ("Got it" / End)
          ElevatedButton(
            onPressed: () {
              controller.endNavigation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEBEBF0),
              foregroundColor: Colors.blue,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Got it',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _getEstimatedTime(double distance) {
    // Assuming walking speed of ~1.4 m/s
    final seconds = distance / 1.4;
    if (seconds < 60) {
      return '< 1 min';
    } else {
      return '${(seconds / 60).ceil()} min';
    }
  }
}
