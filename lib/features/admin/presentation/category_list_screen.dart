import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CATEGORIES')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGold,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => context.go('/admin-categories/add'),
      ).animate().scale(delay: 500.ms),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: 4,
        itemBuilder: (context, index) {
          final categories = ['Starters', 'Main Courses', 'Desserts', 'Beverages'];
          return Card(
            color: AppTheme.surfaceDark,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppTheme.primaryGold.withOpacity(0.3)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              title: Text(categories[index], style: Theme.of(context).textTheme.titleLarge),
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
