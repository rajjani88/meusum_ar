import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/place_controller.dart';
import '../models/place_model.dart';

class PlaceCard extends StatelessWidget {
  final Place place;

  const PlaceCard({Key? key, required this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlaceController>();

    return Obx(() {
      final isSelected = controller.selectedPlace.value?.id == place.id;

      return GestureDetector(
        onTap: () {
          controller.selectPlace(place);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(place.icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                place.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${place.distance.toStringAsFixed(1)}m',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white70 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
