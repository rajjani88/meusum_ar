import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'starter_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Check if permissions are already granted
    final cameraStatus = await Permission.camera.status;
    final locationStatus = await Permission.location.status;

    if (cameraStatus.isGranted && locationStatus.isGranted) {
      _navigateToHome();
    } else {
      setState(() {
        _isChecking = false;
      });
    }
  }

  void _navigateToHome() {
    Get.off(() => const StarterScreen());
  }

  Future<void> _requestPermissions() async {
    // Request permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.location,
    ].request();

    if (statuses[Permission.camera]!.isGranted &&
        statuses[Permission.location]!.isGranted) {
      _navigateToHome();
    } else {
      // Show dialog if permanently denied or just denied
      if (mounted) {
        bool isPermanentlyDenied =
            statuses[Permission.camera]!.isPermanentlyDenied ||
            statuses[Permission.location]!.isPermanentlyDenied;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Permissions Required'),
            content: Text(
              isPermanentlyDenied
                  ? 'Camera and Location permissions are mandatory for AR navigation. Please enable them in app settings.'
                  : 'This app needs Camera and Location access to function. Please grant permissions.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (isPermanentlyDenied) {
                    openAppSettings();
                  } else {
                    _requestPermissions();
                  }
                },
                child: Text(isPermanentlyDenied ? 'Open Settings' : 'Retry'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.security_update_good,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 32),
              const Text(
                'Permissions Required',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'To detect your surroundings and guide you to exhibits, we need access to your Camera and Location.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _requestPermissions,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Grant Permissions',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
