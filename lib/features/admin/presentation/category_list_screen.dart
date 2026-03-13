import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/supabase_providers.dart';

class CategoryListScreen extends ConsumerStatefulWidget {
  const CategoryListScreen({super.key});

  @override
  ConsumerState<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends ConsumerState<CategoryListScreen> {
  String? _selectedRestaurantId;

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(restaurantsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CATEGORIES'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGold,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => context.push('/admin-categories/add'),
      ).animate().scale(delay: 500.ms),
      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: restaurantsAsync.when(
              data: (restaurants) => DropdownButtonFormField<String?>(
                value: _selectedRestaurantId,
                decoration: InputDecoration(
                  labelText: 'Filter by Restaurant',
                  prefixIcon: const Icon(Icons.filter_list, color: AppTheme.primaryGold),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text("All Restaurants")),
                  ...restaurants.map((r) => DropdownMenuItem(
                    value: r['id'] as String,
                    child: Text(r['name'] ?? 'Unknown'),
                  )),
                ],
                onChanged: (val) => setState(() => _selectedRestaurantId = val),
              ),
              loading: () => const LinearProgressIndicator(color: AppTheme.primaryGold),
              error: (err, _) => const SizedBox.shrink(),
            ),
          ),

          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                final activeCategories = categories.where((c) => c['restaurants']?['is_active'] ?? true).toList();

                final filteredCategories = _selectedRestaurantId == null
                    ? activeCategories
                    : activeCategories.where((c) => c['restaurant_id'] == _selectedRestaurantId).toList();

                if (filteredCategories.isEmpty) {
                  return Center(child: Text('No categories found', style: TextStyle(color: AppTheme.primaryGold.withValues(alpha: 0.7))));
                }

                return RefreshIndicator(
                  onRefresh: () => ref.refresh(allCategoriesProvider.future),
                  color: AppTheme.primaryGold,
                  backgroundColor: AppTheme.surfaceDark,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      final restaurantName = category['restaurants']?['name'] ?? 'Unknown Restaurant';

                      return Card(
                        color: AppTheme.surfaceDark,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppTheme.primaryGold.withValues(alpha: 0.3)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          title: Text(category['name'] ?? 'Untitled', style: Theme.of(context).textTheme.titleLarge),
                          subtitle: Text(restaurantName, style: const TextStyle(color: Colors.white70)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _confirmDelete(category),
                          ),
                          onTap: () => context.push('/admin-categories/edit/${category['id']}'),
                        ),
                      ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
              error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${category['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(supabaseServiceProvider).hardDeleteRecord('categories', category['id']);
        ref.invalidate(allCategoriesProvider);
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              const SnackBar(content: Text('Category deleted successfully')),
            );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }
}
