import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/supabase_providers.dart';

class MenuItemListScreen extends ConsumerStatefulWidget {
  const MenuItemListScreen({super.key});

  @override
  ConsumerState<MenuItemListScreen> createState() => _MenuItemListScreenState();
}

class _MenuItemListScreenState extends ConsumerState<MenuItemListScreen> {
  String? _selectedRestaurantId;
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final restaurantsAsync = ref.watch(restaurantsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final itemsAsync = ref.watch(allMenuItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MENU ITEMS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGold,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => context.push('/admin-menu/add'),
      ).animate().scale(delay: 500.ms),
      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Column(
              children: [
                restaurantsAsync.when(
                  data: (restaurants) => DropdownButtonFormField<String?>(
                    value: _selectedRestaurantId,
                    decoration: InputDecoration(
                      labelText: 'Filter by Restaurant',
                      prefixIcon: const Icon(Icons.store, color: AppTheme.primaryGold),
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
                    onChanged: (val) => setState(() {
                      _selectedRestaurantId = val;
                      _selectedCategoryId = null; // Reset category when restaurant changes
                    }),
                  ),
                  loading: () => const LinearProgressIndicator(color: AppTheme.primaryGold),
                  error: (err, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                categoriesAsync.when(
                  data: (categories) {
                    final filteredCategories = _selectedRestaurantId == null
                        ? categories
                        : categories.where((c) => c['restaurant_id'] == _selectedRestaurantId).toList();

                    return DropdownButtonFormField<String?>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: 'Filter by Category',
                        prefixIcon: const Icon(Icons.category, color: AppTheme.primaryGold),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text("All Categories")),
                        ...filteredCategories.map((c) => DropdownMenuItem(
                          value: c['id'] as String,
                          child: Text(c['name'] ?? 'Untitled'),
                        )),
                      ],
                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (err, _) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          Expanded(
            child: itemsAsync.when(
              data: (items) {
                final activeItems = items.where((i) => i['restaurants']?['is_active'] ?? true).toList();

                final filteredItems = activeItems.where((i) {
                  final matchesRestaurant = _selectedRestaurantId == null || i['restaurant_id'] == _selectedRestaurantId;
                  final matchesCategory = _selectedCategoryId == null || i['category_id'] == _selectedCategoryId;
                  return matchesRestaurant && matchesCategory;
                }).toList();

                if (filteredItems.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(allMenuItemsProvider.future),
                    child: ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: Center(child: Text('No menu items found', style: TextStyle(color: AppTheme.primaryGold.withValues(alpha: 0.7)))),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.refresh(allMenuItemsProvider.future),
                  color: AppTheme.primaryGold,
                  backgroundColor: AppTheme.surfaceDark,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      final categoryName = item['categories']?['name'] ?? 'Untracked';
                      final restaurantName = item['restaurants']?['name'] ?? 'Unknown';

                      return Card(
                        color: AppTheme.surfaceDark,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppTheme.primaryGold.withValues(alpha: 0.3)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 60, height: 60,
                            color: Colors.black26,
                            child: const Icon(Icons.fastfood, color: AppTheme.primaryGold),
                          ),
                          title: Text(item['name'] ?? 'Untitled', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('\$${item['price']} • $categoryName ($restaurantName)', style: const TextStyle(color: Colors.white70)),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _confirmDelete(item),
                          ),
                          onTap: () => context.push('/admin-menu/edit/${item['id']}'),
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

  Future<void> _confirmDelete(Map<String, dynamic> item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${item['name']}"?'),
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
        await ref.read(supabaseServiceProvider).hardDeleteRecord('menu_items', item['id']);
        ref.invalidate(allMenuItemsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              const SnackBar(content: Text('Item deleted successfully')),
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
