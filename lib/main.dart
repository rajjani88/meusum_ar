import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/place_controller.dart';
import 'screens/permission_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Museum AR Navigator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PermissionScreen(),
      initialBinding: BindingsBuilder(() {
        Get.put(PlaceController());
      }),
    );
  }
}
