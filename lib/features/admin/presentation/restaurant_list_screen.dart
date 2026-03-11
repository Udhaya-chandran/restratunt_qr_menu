import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class RestaurantListScreen extends StatelessWidget {
  const RestaurantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RESTAURANTS'),
        leading: BackButton(onPressed: () => context.go('/dashboard')),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGold,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => context.go('/restaurants/add'),
      ).animate().scale(delay: 500.ms),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Card(
            color: AppTheme.surfaceDark,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppTheme.primaryGold.withOpacity(0.3)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.store, color: AppTheme.primaryGold),
              ),
              title: Text('Location ${index + 1}', style: Theme.of(context).textTheme.titleLarge),
              subtitle: const Text('123 Culinary Ave, Paris', style: TextStyle(color: Colors.white70)),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: AppTheme.primaryGold),
                onPressed: () {},
              ),
            ),
          ).animate().fadeIn(delay: (150 * index).ms).slideX(begin: 0.1);
        },
      ),
    );
  }
}
