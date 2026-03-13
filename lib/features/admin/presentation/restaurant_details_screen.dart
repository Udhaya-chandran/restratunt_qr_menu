import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/supabase_providers.dart';

class RestaurantDetailsScreen extends ConsumerWidget {
  final String restaurantId;

  const RestaurantDetailsScreen({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurantAsync = ref.watch(restaurantDetailsProvider(restaurantId));

    return Scaffold(
      body: restaurantAsync.when(
        data: (restaurant) {
          final name = restaurant['name'] ?? 'Untitled';
          final address = restaurant['city'] ?? 'No address';
          final phone = restaurant['phone'] ?? 'No phone';
          final slug = restaurant['slug'] ?? '';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: Colors.black26,
                        child: const Icon(Icons.store, size: 80, color: AppTheme.primaryGold),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                      ).animate().fadeIn(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppTheme.primaryGold, size: 18),
                          const SizedBox(width: 8),
                          Text(address, style: const TextStyle(color: Colors.white70)),
                        ],
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, color: AppTheme.primaryGold, size: 18),
                          const SizedBox(width: 8),
                          Text(phone, style: const TextStyle(color: Colors.white70)),
                        ],
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 24),
                      
                      // Active/Inactive Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.2)),
                        ),
                        child: SwitchListTile(
                          title: const Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          subtitle: Text(
                            restaurant['is_active'] == true ? 'Online & Visible' : 'Temporarily Closed',
                            style: TextStyle(color: restaurant['is_active'] == true ? Colors.greenAccent : Colors.redAccent),
                          ),
                          value: restaurant['is_active'] ?? true,
                          activeColor: AppTheme.primaryGold,
                          onChanged: (val) async {
                            try {
                              await ref.read(supabaseServiceProvider).updateRestaurantStatus(restaurantId, val);
                              ref.invalidate(restaurantsProvider);
                              ref.invalidate(allCategoriesProvider);
                              ref.invalidate(allMenuItemsProvider);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                  ..clearSnackBars()
                                  ..showSnackBar(
                                    SnackBar(content: Text(val ? 'Restaurant is now Active' : 'Restaurant is now Inactive')),
                                  );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                  ..clearSnackBars()
                                  ..showSnackBar(SnackBar(content: Text('Error: $e')));
                              }
                            }
                          },
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 40),
                      
                      // Action Buttons
                      ElevatedButton.icon(
                        onPressed: () => context.push('/restaurants/edit/$restaurantId'),
                        icon: const Icon(Icons.edit, color: Colors.black),
                        label: const Text('EDIT RESTAURANT', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ).animate().slideY(begin: 0.2, delay: 300.ms),
                      
                      const SizedBox(height: 16),
                      
                      OutlinedButton.icon(
                        onPressed: () => context.push(
                          Uri(
                            path: '/qr-generator',
                            queryParameters: {
                              'slug': slug,
                              'name': name,
                            },
                          ).toString(),
                        ),
                        icon: const Icon(Icons.qr_code, color: AppTheme.primaryGold),
                        label: const Text('GENERATE QR CODE', style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryGold),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ).animate().slideY(begin: 0.2, delay: 400.ms),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
