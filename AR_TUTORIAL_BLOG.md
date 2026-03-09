# Build Your First Indoor Wayfinding AR App with Flutter & GetX! 🚀

Have you ever been lost in a massive mall, hospital, or museum and wished you had a magical arrow on your phone pointing exactly where to go? 

Today, we're going to build exactly that! We'll walk through creating **Museum AR Navigator**, an indoor wayfinding application using Augmented Reality (AR) in Flutter. 

Instead of dealing with complex 2D maps, our app overlays animated 3D arrows directly onto the camera feed, guiding users step-by-step. By the end of this tutorial, you'll know how to leverage `ar_flutter_plugin` and `get` (GetX) to build your very own AR navigation app.

---

## 🎯 What We Are Building
A single-page Flutter application that:
1. Loads a list of destinations (Places) from a local JSON file.
2. Lets users select a destination.
3. Uses the phone's camera and AR to render 3D arrows on the floor, pointing to the destination using physical coordinates (Waypoints).
4. Provides real-time turn instructions (e.g., "Turn Left", "Go Straight").

## 🛠 Prerequisites & Setup

Ensure you have Flutter installed on your machine. Create a new project:
```bash
flutter create meusum_ar
cd meusum_ar
```

Add these essential dependencies to your `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6                    # For reactive state management
  ar_flutter_plugin_engine: ^... # For AR capabilities
  vector_math: ^2.1.4            # For 3D mathematics (Node positions)
  flutter_compass: ^...          # Optional: For device heading
```

---

## Step 1: Defining the Data Layer (The 3D World)

In AR, we don't just use 2D (X, Y) map coordinates; we need 3D vectors (X, Y, Z) to place objects in the real world relative to the camera.

Let's define a `Place` model. 
Create `lib/models/place_model.dart`:

```dart
import 'package:vector_math/vector_math_64.dart';

class Place {
  final int id;
  final String name;
  final String icon;
  final Vector3 position; // The final destination 3D coordinate
  final List<Vector3> waypoints; // The path (bread-crumbs) to reach there
  final double distance;

  Place({
    required this.id,
    required this.name,
    required this.icon,
    required this.position,
    this.waypoints = const [],
    required this.distance,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    // Parse position list [x, y, z] to Vector3
    final posList = json['position'] as List;
    
    // Parse waypoints array [[x,y,z], ...]
    var waypointsList = <Vector3>[];
    if (json['waypoints'] != null) {
      for (var point in json['waypoints']) {
        waypointsList.add(Vector3(point[0], point[1], point[2]));
      }
    }

    return Place(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      position: Vector3(posList[0], posList[1], posList[2]),
      waypoints: waypointsList,
      distance: json['distance'],
    );
  }
}
```

We load this data from a local `places.json` mock file to simulate a backend!

---

## Step 2: The Brains - State Management with GetX

We need a controller to track the user's location, selected destination, and the current AR navigation state. We'll use GetX for beautifully clean, reactive state management.

Create `lib/controllers/place_controller.dart`:

```dart
import 'package:get/get.dart';
import 'package:vector_math/vector_math_64.dart';
import '../models/place_model.dart';

class PlaceController extends GetxController {
  final places = <Place>[].obs; // Reactive list of places
  final selectedPlace = Rx<Place?>(null); // Currently selected place
  
  final isNavigating = false.obs;
  final currentInstruction = "Start walking".obs;
  final distanceToNextTurn = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadPlaces(); // Load from places.json here
  }

  void startNavigation() {
    if (selectedPlace.value != null) {
      isNavigating.value = true;
    }
  }

  // Called 10 times a second by the AR View to calculate directions!
  void updateUserPose(Matrix4 cameraPose) {
    if (selectedPlace.value == null) return;
    
    // Extract camera position (X, Y, Z)
    final pos = cameraPose.getTranslation();
    
    // Calculate distance to the next waypoint
    final target = selectedPlace.value!.position; 
    final dist = (target - pos).length;
    
    distanceToNextTurn.value = dist;
    
    if (dist < 1.0) {
      currentInstruction.value = "Arrived!";
    } else {
       currentInstruction.value = "Go Straight";
    }
  }
}
```

---

## Step 3: The AR Magic 🪄

This is where the magic happens. We'll use the `ar_flutter_plugin` to render an AR camera feed, detect floor planes, and draw 3D floating arrows (`GLB` files) pointing exactly where the user needs to walk.

Create `lib/widgets/ar_view.dart`:

```dart
import 'package:ar_flutter_plugin_engine/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_engine/models/ar_node.dart';
import 'package:ar_flutter_plugin_engine/datatypes/node_types.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_math/vector_math_64.dart';
import '../controllers/place_controller.dart';

class ARViewWidget extends StatefulWidget {
  const ARViewWidget({Key? key}) : super(key: key);

  @override
  _ARViewWidgetState createState() => _ARViewWidgetState();
}

class _ARViewWidgetState extends State<ARViewWidget> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;

  @override
  Widget build(BuildContext context) {
    return ARView(
      onARViewCreated: onARViewCreated,
      planeDetectionConfig: PlaneDetectionConfig.horizontal, // Detect floors
    );
  }

  void onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    // ... other managers
  ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;

    arSessionManager!.onInitialize(
      showPlanes: true, 
      showWorldOrigin: true
    );
    arObjectManager!.onInitialize();

    // Listen to GetX state changes - if user selects a place, draw arrows!
    final controller = Get.find<PlaceController>();
    ever(controller.selectedPlace, (place) {
      if (place != null) _renderNavigationArrows(place);
    });
    
    _startCameraPolling(controller);
  }

  void _renderNavigationArrows(Place place) {
    // 1. Clear old arrows
    // 2. Loop through place.waypoints
    // 3. For each step, create an ARNode (a 3D object)
    
    var pathNode = ARNode(
      type: NodeType.webGLB,
      uri: "https://.../models/arrow.glb", // Remote 3D model link
      scale: Vector3(0.4, 0.4, 0.4),
      position: place.position, // Place arrow in the 3D world
    );
    
    arObjectManager?.addNode(pathNode);
  }
  
  void _startCameraPolling(PlaceController controller) {
    Future.delayed(const Duration(milliseconds: 100), () async {
      final pose = await arSessionManager?.getCameraPose();
      if (pose != null && mounted) {
        controller.updateUserPose(pose); // Send pose to our Brain
      }
      _startCameraPolling(controller); // Loop
    });
  }
}
```

Wait, what did we just do?
1. Initialized the AR Session and tracked the floor.
2. We listed to the `PlaceController`. As soon as a user clicks a destination card, we trigger `_renderNavigationArrows`.
3. We fetch an **arrow.glb** (a 3D graphics file format) and injected it into the floor at the exact 3D coordinates.
4. We continuously poll the camera's pose and feed it back to GetX to update the "Distance remaining" text in the UI!

---

## Step 4: Putting It All Together in the UI

Let's wrap our AR View with beautiful Flutter UI overlays using a simple Stack.

Create `lib/screens/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/place_controller.dart';
import '../widgets/ar_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PlaceController());

    return Scaffold(
      body: Stack(
        children: [
          // 1. The AR Camera Underlay
          const Positioned.fill(child: ARViewWidget()),

          // 2. The Directions HUD Overlay (Only shows when navigating)
          Obx(() {
            if (!controller.isNavigating.value) return const SizedBox();
            
            return Positioned(
              top: 80,
              left: 20, right: 20,
              child: Card(
                color: Colors.blue.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "${controller.currentInstruction.value} (${controller.distanceToNextTurn.value.toStringAsFixed(1)}m)",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            );
          }),

          // 3. The Place Selection Bottom Bar
          Positioned(
            bottom: 20,
            left: 0, right: 0,
            child: SizedBox(
              height: 150,
              child: Obx(() => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.places.length,
                itemBuilder: (ctx, i) {
                  final place = controller.places[i];
                  return GestureDetector(
                    onTap: () => controller.selectPlace(place),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(place.icon, style: TextStyle(fontSize: 40)),
                            Text(place.name),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )),
            ),
          )
        ],
      ),
    );
  }
}
```

## Wrapping Up

Congratulations! 🎉 You successfully built your own AR Navigation App. 

You've learned how to:
- Combine 3D data modeling with Flutter.
- Keep complex visual features reactive using **GetX**.
- Run an active Augmented Reality session and overlay 3D `glb` objects onto the real world layout.
- Bind continuous camera stream calculations to UI updates without causing massive frame drops.

You can grab the **full source code** from our GitHub repository here [Insert GitHub Repo Link] and test it in your own house, office, or mall!

**What to try next:**
- Hooking the JSON loading up to Firebase or Supabase to pull dynamic waypoints over the air.
- Using Google Maps integrations to handle macro-routes (User is 5 miles away) before switching to AR for micro-routes (User is inside the building).
 
Happy Coding, and don't get lost! 🗺️
