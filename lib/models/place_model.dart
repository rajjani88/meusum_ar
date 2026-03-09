import 'package:vector_math/vector_math_64.dart';

class Place {
  final int id;
  final String name;
  final String icon;
  final String description;
  final double latitude;
  final double longitude;
  final Vector3 position;
  final String section;
  final double distance;
  final String arImageUrl;
  final List<Vector3> waypoints; // Intermediate path points

  Place({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.position,
    this.waypoints = const [], // Default empty
    required this.section,
    required this.distance,
    required this.arImageUrl,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    // Parse position list [x, y, z] to Vector3
    final positionList =
        (json['position'] as List?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [0.0, 0.0, -1.0];

    // Parse waypoints list of lists [[x,y,z], ...]
    var waypointsList = <Vector3>[];
    if (json['waypoints'] != null) {
      final list = json['waypoints'] as List;
      for (var point in list) {
        final p = (point as List).map((e) => (e as num).toDouble()).toList();
        waypointsList.add(Vector3(p[0], p[1], p[2]));
      }
    }

    return Place(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      position: Vector3(positionList[0], positionList[1], positionList[2]),
      waypoints: waypointsList,
      section: json['section'] as String,
      distance: (json['distance'] as num).toDouble(),
      arImageUrl: json['arImageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'position': [position.x, position.y, position.z],
      'waypoints': waypoints.map((v) => [v.x, v.y, v.z]).toList(),
      'section': section,
      'distance': distance,
      'arImageUrl': arImageUrl,
    };
  }
}
