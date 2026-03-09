import 'dart:math' as math;
import 'package:ar_flutter_plugin_engine/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_engine/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_engine/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_engine/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_engine/models/ar_node.dart';
import 'package:ar_flutter_plugin_engine/models/ar_anchor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import '../controllers/place_controller.dart';
import '../models/place_model.dart';

class ARViewWidget extends StatefulWidget {
  const ARViewWidget({Key? key}) : super(key: key);

  @override
  _ARViewWidgetState createState() => _ARViewWidgetState();
}

class _ARViewWidgetState extends State<ARViewWidget> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  bool _isSetup = false;
  List<ARNode> _nodes = [];
  List<ARAnchor> _anchors = [];

  @override
  void dispose() {
    super.dispose();
    arSessionManager?.dispose();
    _clearObjects();
  }

  void _clearObjects() {
    for (var node in _nodes) {
      arObjectManager?.removeNode(node);
    }
    _nodes.clear();
    for (var anchor in _anchors) {
      arAnchorManager?.removeAnchor(anchor);
    }
    _anchors.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                    ],
                    stops: const [0.0, 0.2, 0.8, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onARViewCreated(
    ARSessionManager arSessionManager,
    ARObjectManager arObjectManager,
    ARAnchorManager arAnchorManager,
    ARLocationManager arLocationManager,
  ) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;

    this.arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: true,
      handleTaps: false,
    );
    this.arObjectManager!.onInitialize();

    _isSetup = true;

    // Listen to changes in PlaceController
    final controller = Get.find<PlaceController>();

    // If a place is already selected, render it
    if (controller.selectedPlace.value != null) {
      _renderNavigation(controller.selectedPlace.value!);
    }

    ever(controller.selectedPlace, (place) {
      if (place != null && _isSetup) {
        _renderNavigation(place);
      }
    });

    // Start polling camera pose for navigation updates
    _startCameraPolling(controller);
  }

  void _startCameraPolling(PlaceController controller) {
    // Poll every 100ms
    Future.delayed(const Duration(milliseconds: 100), () async {
      if (mounted && _isSetup) {
        final pose = await arSessionManager?.getCameraPose();
        if (pose != null) {
          // Always update current position for Admin mode capture
          controller.currentCameraPosition.value = pose.getTranslation();

          // Navigation updates
          if (controller.isNavigating.value) {
            controller.updateUserPose(pose);
          }
        }
      }
      _startCameraPolling(controller);
    });
  }

  Future<void> _renderNavigation(Place place) async {
    // Clear existing objects and internal lists
    _clearObjects();

    // Start position (camera/user) is (0,0,0) relative to world origin
    // Adjusted height: 0.2m below camera (chest level) instead of -0.5m (knees)
    final start = Vector3(0, -0.2, 0);

    // If we have recorded waypoints, use them
    if (place.waypoints.isNotEmpty) {
      Vector3 currentPos = start;

      // Generate nodes through all waypoints
      for (var point in place.waypoints) {
        _generatePathSegment(currentPos, point);
        currentPos = point;
      }
      // Add destination marker
      _generateDestinationMarker(currentPos);
    } else {
      // Fallback: Straight line to destination
      final end = place.position;
      _generatePathSegment(start, end);
      _generateDestinationMarker(end);
    }
  }

  void _generatePathSegment(Vector3 from, Vector3 to) {
    final direction = to - from;
    final distance = direction.length;
    final step = 1.0; // 1 meter spacing

    direction.normalize();

    // Calculate rotation to face the direction
    final rotation = _calculateRotationQuaternion(Vector3(0, 0, -1), direction);

    for (double d = 0.5; d < distance; d += step) {
      final pos = from + (direction * d);

      // Adjusted Y-offset to be closer to eye level but visible
      final visualPos = pos + Vector3(0, 0.0, 0);

      var pathNode = ARNode(
        type: NodeType.webGLB,
        uri:
            "https://cdn.jsdelivr.net/gh/chrisraff/3d-maze@master/models/arrow.glb",
        scale: Vector3(0.4, 0.4, 0.4), // Increased scale
        position: visualPos,
        rotation: rotation,
      );

      arObjectManager?.addNode(pathNode);
      _nodes.add(pathNode);
    }
  }

  void _generateDestinationMarker(Vector3 position) {
    // Pole
    var poleNode = ARNode(
      type: NodeType.webGLB,
      uri:
          "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Box/glTF-Binary/Box.glb",
      scale: Vector3(0.05, 1.5, 0.05),
      position: position + Vector3(0, 0.75, 0),
    );
    arObjectManager?.addNode(poleNode);
    _nodes.add(poleNode);

    // Sign Top
    var signNode = ARNode(
      type: NodeType.webGLB,
      uri:
          "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Box/glTF-Binary/Box.glb",
      scale: Vector3(0.5, 0.3, 0.05),
      position: position + Vector3(0, 1.5, 0),
    );
    arObjectManager?.addNode(signNode);
    _nodes.add(signNode);
  }

  // Helper to calculate quaternion between two vectors
  Vector4 _calculateRotationQuaternion(Vector3 source, Vector3 dest) {
    source.normalize();
    dest.normalize();

    double dot = source.dot(dest);

    if (dot >= 1.0) {
      return Vector4(0, 0, 0, 1); // Identity
    }

    if (dot < -0.999999) {
      // Anti-parallel
      Vector3 axis = Vector3(1, 0, 0).cross(source);
      if (axis.length2 == 0) {
        axis = Vector3(0, 1, 0).cross(source);
      }
      axis.normalize();
      // 180 degree rotation around axis
      return Vector4(axis.x, axis.y, axis.z, 0);
    }

    Vector3 cross = source.cross(dest);
    double s = math.sqrt((1 + dot) * 2);
    double invS = 1 / s;

    double x = cross.x * invS;
    double y = cross.y * invS;
    double z = cross.z * invS;
    double w = s * 0.5;

    return Vector4(x, y, z, w);
  }
}
