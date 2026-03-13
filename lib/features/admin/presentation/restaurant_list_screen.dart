import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/supabase_providers.dart';

class RestaurantListScreen extends ConsumerWidget {
  const RestaurantListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantsAsync = ref.watch(restaurantsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RESTAURANTS'),
        leading: BackButton(onPressed: () => context.go('/dashboard')),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGold,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => context.push('/restaurants/add'),
      ).animate().scale(delay: 500.ms),
      body: restaurantsAsync.when(
        data: (restaurants) {
          if (restaurants.isEmpty) {
            return Center(
              child: Text(
                'No restaurants found.\nAdd your first one!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.primaryGold.withValues(alpha: 0.7)),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(restaurantsProvider.future),
            color: AppTheme.primaryGold,
            backgroundColor: AppTheme.surfaceDark,
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = restaurants[index];
                return Card(
                  color: AppTheme.surfaceDark,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppTheme.primaryGold.withValues(alpha: 0.3)),
                  ),
                  child: ListTile(
                    onTap: () => context.push('/restaurants/${restaurant['id']}'),
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.store, color: AppTheme.primaryGold),
                    ),
                    title: Text(restaurant['name'] ?? 'Unknown', style: Theme.of(context).textTheme.titleLarge),
                    subtitle: Text(restaurant['city'] ?? 'No address', style: const TextStyle(color: Colors.white70)),
                  ),
                ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
