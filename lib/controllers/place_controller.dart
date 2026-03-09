import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:get/get.dart';
import 'package:meusum_ar/utils/show_log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import '../models/place_model.dart';

class PlaceController extends GetxController {
  final places = <Place>[].obs;
  final selectedPlace = Rx<Place?>(null);
  final userLat = 40.7128.obs;
  final userLng = RxDouble(-74.0060);
  final userHeading = 0.0.obs;
  final isArMode = false.obs;

  // Navigation State
  final currentInstruction = "Start walking".obs;
  final instructionIcon = Rx<IconData>(Icons.straight);
  final distanceToNextTurn = 0.0.obs;
  final targetRelativeAngle =
      0.0.obs; // In radians, for real-time arrow rotation
  int _currentWaypointIndex = 0;

  StreamSubscription<CompassEvent>? _compassSubscription;

  final isNavigating = false.obs;

  final currentCameraPosition = Vector3.zero().obs; // For capturing location

  @override
  void onInit() {
    super.onInit();
    loadPlaces();
    _initCompass();
  }

  @override
  void onClose() {
    _compassSubscription?.cancel();
    super.onClose();
  }

  void _initCompass() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        userHeading.value = event.heading!;
      }
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/places.json');
  }

  Future<void> loadPlaces() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final jsonData = jsonDecode(contents);
        final placesList = (jsonData['places'] as List)
            .map((place) => Place.fromJson(place as Map<String, dynamic>))
            .toList();
        places.assignAll(placesList);
      } else {
        // Start with empty list if no local file exists
        places.clear();
      }
    } catch (e) {
      showLog("Error loading places: $e");
    }
  }

  Future<void> savePlaces() async {
    try {
      final file = await _localFile;
      final jsonMap = {'places': places.map((p) => p.toJson()).toList()};
      await file.writeAsString(jsonEncode(jsonMap));
    } catch (e) {
      showLog("Error saving places: $e");
    }
  }

  Future<void> addPlace(Place newPlace) async {
    places.add(newPlace);
    await savePlaces();
  }

  Future<void> updatePlace(Place updatedPlace) async {
    final index = places.indexWhere((p) => p.id == updatedPlace.id);
    if (index != -1) {
      places[index] = updatedPlace;
      await savePlaces();
      places.refresh(); // Notify listeners
    }
  }

  Future<void> deletePlace(int id) async {
    places.removeWhere((p) => p.id == id);
    await savePlaces();
    // If deleted place was selected, clear selection
    if (selectedPlace.value?.id == id) {
      selectedPlace.value = null;
      isNavigating.value = false;
    }
  }

  void selectPlace(Place place) {
    selectedPlace.value = place;
    // Auto-start navigation for now? Or wait for user to click "Start"?
    // For now, selecting implies interest, but let's make it explicit in UI.
  }

  void startNavigation() {
    if (selectedPlace.value != null) {
      isNavigating.value = true;
    }
  }

  void endNavigation() {
    isNavigating.value = false;
    selectedPlace.value = null;
  }

  void toggleArMode() {
    isArMode.toggle();
  }

  double getDistanceToPlace() {
    if (selectedPlace.value == null) return 0;
    return selectedPlace.value!.distance;
  }

  String getDirectionArrow() {
    if (selectedPlace.value == null) return '↑';

    final place = selectedPlace.value!;
    final userLatValue = userLat.value;
    final userLngValue = userLng.value;

    double dLat = place.latitude - userLatValue;
    double dLng = place.longitude - userLngValue;

    double angle = (math.atan2(dLng, dLat) * 180 / math.pi);

    if (angle < 0) angle += 360;

    if (angle < 22.5 || angle >= 337.5) return '↑';
    if (angle < 67.5) return '↗';
    if (angle < 112.5) return '→';
    if (angle < 157.5) return '↘';
    if (angle < 202.5) return '↓';
    if (angle < 247.5) return '↙';
    if (angle < 292.5) return '←';
    if (angle < 337.5) return '↖';

    return '↑';
  }

  double getDirectionAngle() {
    if (selectedPlace.value == null) return 0;

    final place = selectedPlace.value!;
    final userLatValue = userLat.value;
    final userLngValue = userLng.value;

    double dLat = place.latitude - userLatValue;
    double dLng = place.longitude - userLngValue;

    double angle = (math.atan2(dLng, dLat) * 180 / math.pi);
    if (angle < 0) angle += 360;

    return angle;
  }

  void updateUserPose(Matrix4 cameraPose) {
    if (selectedPlace.value == null) return;
    final place = selectedPlace.value!;

    // Extract position
    final pos = cameraPose.getTranslation();

    // Extract Forward vector from Camera Matrix (Column 2 is -Z usually)
    // In ARCore/Kit, standard is -Z forward.
    final forward = -cameraPose.getColumn(2).xyz;

    // Find target point
    // If we have waypoints, use them. Else use destination.
    Vector3 target = place.position;
    if (place.waypoints.isNotEmpty) {
      if (_currentWaypointIndex < place.waypoints.length) {
        target = place.waypoints[_currentWaypointIndex];
      } else {
        target = place.position;
      }
    }

    // Check distance to target
    final dist = (target - pos).length;
    distanceToNextTurn.value = dist;

    // If close to waypoint, advance
    if (dist < 1.5 &&
        place.waypoints.isNotEmpty &&
        _currentWaypointIndex < place.waypoints.length) {
      _currentWaypointIndex++;
      // Recalculate target
      if (_currentWaypointIndex < place.waypoints.length) {
        target = place.waypoints[_currentWaypointIndex];
      } else {
        target = place.position;
      }
    }

    // Determine Turn Instruction relative to Camera Forward
    // Vector to target relative to camera pos
    final toTarget = target - pos;
    toTarget.normalize();
    forward.normalize();

    // Dot product gives us "front/back". Cross product gives "left/right".
    // 2D projection (XZ plane) is usually enough for floor navigation.
    final forward2D = Vector2(forward.x, -forward.z).normalized(); // Map Z to Y
    final target2D = Vector2(toTarget.x, -toTarget.z).normalized();

    // Angle
    final double angle =
        math.atan2(target2D.y, target2D.x) -
        math.atan2(forward2D.y, forward2D.x);

    // Normalize angle to -PI to PI
    double angleDiff = angle;
    if (angleDiff > math.pi) angleDiff -= 2 * math.pi;
    if (angleDiff < -math.pi) angleDiff += 2 * math.pi;

    // Set relative angle for arrow rotation (negate because Transform.rotate is clockwise)
    targetRelativeAngle.value = -angleDiff;

    double angleDeg = angleDiff * 180 / math.pi;

    // Logic
    if (dist < 1.0 && _currentWaypointIndex >= place.waypoints.length) {
      currentInstruction.value = "Arrived";
      instructionIcon.value = Icons.check_circle;
    } else if (angleDeg.abs() > 150) {
      currentInstruction.value = "Turn Around";
      instructionIcon.value = Icons.u_turn_left;
    } else if (angleDeg > 20) {
      currentInstruction.value = "Turn Left";
      instructionIcon.value = Icons.turn_left;
    } else if (angleDeg < -20) {
      currentInstruction.value = "Turn Right";
      instructionIcon.value = Icons.turn_right;
    } else {
      currentInstruction.value = "Go Straight";
      instructionIcon.value = Icons.straight;
    }
  }
}
