import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meusum_ar/screens/admin/admin_dashboard.dart';
import 'package:meusum_ar/screens/home_screen.dart';

class StarterScreen extends StatelessWidget {
  const StarterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade800, Colors.purple.shade900],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.museum_outlined, size: 100, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Museum AR',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 48),

              // User Mode Button
              _buildModeButton(
                context,
                title: 'User Mode',
                icon: Icons.person,
                color: Colors.white,
                textColor: Colors.blue.shade900,
                onTap: () {
                  Get.to(() => const HomeScreen());
                },
              ),

              const SizedBox(height: 24),

              // Admin Mode Button
              _buildModeButton(
                context,
                title: 'Admin Mode',
                icon: Icons.admin_panel_settings,
                color: Colors.white.withOpacity(0.2),
                textColor: Colors.white,
                onTap: () {
                  Get.to(() => const AdminDashboard());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
