import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/place_controller.dart';
import '../widgets/ar_view.dart';
import '../widgets/minimap_overlay.dart';

import '../widgets/navigation_sheet.dart';
import 'admin/admin_dashboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlaceController>(
      init: PlaceController(),
      builder: (controller) {
        return Scaffold(
          body: Stack(
            children: [
              // 1. Full Screen AR View
              const Positioned.fill(child: ARViewWidget()),

              // 2. Safe Area Top Overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Museum Guide',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        // Admin Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Get.to(() => const AdminDashboard());
                            },
                            tooltip: 'Admin Mode',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. UI Layer (Observed)
              Obx(() {
                final isNavigating = controller.isNavigating.value;
                final selectedPlace = controller.selectedPlace.value;

                return Stack(
                  children: [
                    if (isNavigating)
                      const Positioned(
                        bottom: 180,
                        right: 16,
                        child: MinimapOverlay(),
                      ),

                    // Direction Instruction Overlay
                    if (isNavigating)
                      Positioned(
                        top: 100,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Obx(
                                  () => Transform.rotate(
                                    angle: controller.targetRelativeAngle.value,
                                    child: const Icon(
                                      Icons.navigation,
                                      color: Colors.white,
                                      size: 36,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(
                                      () => Text(
                                        controller.currentInstruction.value,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Obx(
                                      () => Text(
                                        "${controller.distanceToNextTurn.value.toStringAsFixed(1)}m",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Bottom Interface
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isNavigating && selectedPlace != null
                            ? NavigationSheet(
                                key: const ValueKey('nav_sheet'),
                                place: selectedPlace,
                              )
                            : _buildBrowsingList(controller),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrowsingList(PlaceController controller) {
    if (controller.places.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black87],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, color: Colors.white54, size: 48),
            const SizedBox(height: 16),
            const Text(
              "No places found.",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            TextButton(
              onPressed: () => Get.to(() => const AdminDashboard()),
              child: const Text(
                "Go to Admin to add places",
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      key: const ValueKey('browsing_list'),
      height: 300,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black54, Colors.black87],
          stops: [0.0, 0.3, 1.0],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                const Text(
                  "Explore Places",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  "${controller.places.length} places",
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 160,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: controller.places.length,
              itemBuilder: (context, index) {
                final place = controller.places[index];
                return GestureDetector(
                  onTap: () => controller.selectPlace(place),
                  child: Container(
                    width: 128,
                    margin: const EdgeInsets.only(
                      right: 12,
                      bottom: 12,
                      top: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15), // Glassmorphism
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(place.icon, style: const TextStyle(fontSize: 38)),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            place.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (controller.selectedPlace.value == place)
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Selected",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // "Start Navigation" Button
          Obx(() {
            if (controller.selectedPlace.value != null &&
                !controller.isNavigating.value) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 4),
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.startNavigation();
                    },
                    icon: const Icon(Icons.navigation, color: Colors.white),
                    label: const Text(
                      'Start Navigation',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 8,
                      shadowColor: Colors.blueAccent.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox(height: 24); // Spacing placeholder
          }),
        ],
      ),
    );
  }
}
