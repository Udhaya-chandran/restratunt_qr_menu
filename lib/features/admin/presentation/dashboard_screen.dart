import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DASHBOARD'),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: AppTheme.primaryGold), onPressed: () => context.go('/signin')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildDashboardCard(context, 'Restaurants', Icons.store, () => context.go('/restaurants')),
          const SizedBox(height: 16),
          // Will add Category & Menu routing later
          _buildDashboardCard(context, 'Categories', Icons.category, () {}), 
          const SizedBox(height: 16),
          _buildDashboardCard(context, 'Menu Items', Icons.restaurant_menu, () {}),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: AppTheme.primaryGold),
            const SizedBox(width: 24),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
