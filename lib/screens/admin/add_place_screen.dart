import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meusum_ar/controllers/place_controller.dart';
import 'package:meusum_ar/models/place_model.dart';
import 'package:meusum_ar/widgets/ar_view.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({Key? key}) : super(key: key);

  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _controller = Get.find<PlaceController>();

  // Recording State
  bool _isRecording = false;
  final List<vector.Vector3> _recordedWaypoints = [];
  Timer? _recordingTimer;

  // Default icon
  String _selectedIcon = '📍';
  final List<String> _icons = ['📍', '🖼️', '🗿', '🏺', '🦕', '🍔', '🚻'];

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background AR View
          const ARViewWidget(),

          // Header
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Get.back(),
            ),
          ),

          // Recording Overlay (Top Right)
          Positioned(
            top: 50,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Waypoints: ${_recordedWaypoints.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  if (_isRecording)
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Colors.red, size: 12),
                        SizedBox(width: 8),
                        Text(
                          'RECORDING...',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // Form Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Place',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Name Field
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Place Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  TextField(
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Icon Selection
                  const Text(
                    'Select Icon:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _icons.length,
                      itemBuilder: (context, index) {
                        final icon = _icons[index];
                        final isSelected = icon == _selectedIcon;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIcon = icon;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: Colors.blue, width: 2)
                                  : null,
                            ),
                            child: Text(
                              icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recording Controls
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleRecording,
                          icon: Icon(
                            _isRecording
                                ? Icons.stop
                                : Icons.fiber_manual_record,
                            color: _isRecording ? Colors.red : Colors.green,
                          ),
                          label: Text(_isRecording ? 'Stop Rec' : 'Start Path'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: _isRecording ? Colors.red : Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addWaypointManual,
                          icon: const Icon(Icons.add_location_alt),
                          label: const Text('Drop Point'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Capture Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _savePlace,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Save Place & Path'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      // Clear previous if any? Or append? Let's clear for fresh start usually.
      if (_recordedWaypoints.isNotEmpty) {
        // Maybe ask user? For now, we assume new recording overwrites or appends?
        // Let's just append or keep as is.
      }
      _startRecordingTimer();
    } else {
      _recordingTimer?.cancel();
    }
  }

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }
      _recordPointIfNeeded();
    });
  }

  void _recordPointIfNeeded() {
    final currentPos = _controller.currentCameraPosition.value;

    // Don't record (0,0,0) if it's likely uninitialized, unless it's the very start
    // But (0,0,0) is valid start.

    if (_recordedWaypoints.isEmpty) {
      _recordedWaypoints.add(
        vector.Vector3(currentPos.x, currentPos.y, currentPos.z),
      );
      setState(() {});
      return;
    }

    final lastPoint = _recordedWaypoints.last;
    final dist = currentPos.distanceTo(lastPoint);

    // Record if moved more than 1 meter
    if (dist > 1.0) {
      _recordedWaypoints.add(
        vector.Vector3(currentPos.x, currentPos.y, currentPos.z),
      );
      setState(() {});
    }
  }

  void _addWaypointManual() {
    final currentPos = _controller.currentCameraPosition.value;
    _recordedWaypoints.add(
      vector.Vector3(currentPos.x, currentPos.y, currentPos.z),
    );
    setState(() {});
    Get.snackbar('Point Added', 'Manual waypoint dropped.');
  }

  void _savePlace() {
    if (_nameController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a name');
      return;
    }

    // Capture position from accessible observable
    // We assume the user is standing at the location
    final position = _controller.currentCameraPosition.value;

    // We also need "dummy" GPS coords because the model requires them,
    // even though we rely on vector position for AR.
    // For now, we can just use the user's current GPS or 0,0 if not available.
    final lat = _controller.userLat.value;
    final lng = _controller.userLng.value;

    final newPlace = Place(
      id: DateTime.now().millisecondsSinceEpoch, // Unique ID as int
      name: _nameController.text,
      description: _descController.text,
      icon: _selectedIcon,
      latitude: lat,
      longitude: lng,
      position: vector.Vector3(position.x, position.y, position.z),
      waypoints: List.from(_recordedWaypoints), // Save the path
      arImageUrl: 'assets/images/placeholder.jpg', // Default
      distance: 0, // Recalculated dynamically
      section: 'User Added',
    );

    _controller.addPlace(newPlace);
    Get.back();
    Get.snackbar('Success', 'Place added successfully!');
  }
}
