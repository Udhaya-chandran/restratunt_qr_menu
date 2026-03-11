import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class MenuItemListScreen extends StatelessWidget {
  const MenuItemListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MENU ITEMS')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGold,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => context.go('/admin-menu/add'),
      ).animate().scale(delay: 500.ms),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: 5,
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
                color: Colors.black26,
                child: const Icon(Icons.fastfood, color: AppTheme.primaryGold),
              ),
              title: Text('Gourmet Dish ${index + 1}', style: Theme.of(context).textTheme.titleLarge),
              subtitle: Text('\$${(index + 2) * 12}.00 • Category Name', style: const TextStyle(color: Colors.white70)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.qr_code, color: Colors.white),
                    onPressed: () => context.go('/qr-generator'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppTheme.primaryGold),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (150 * index).ms).slideX(begin: 0.1);
        },
      ),
    );
  }
}
