import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/supabase_providers.dart';

class MenuScreen extends ConsumerStatefulWidget {
  final String restaurantSlug;
  final String categoryId;
  
  const MenuScreen({
    super.key, 
    required this.restaurantSlug, 
    required this.categoryId,
  });

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantAsync = ref.watch(currentRestaurantProvider(widget.restaurantSlug));
    final itemsAsync = ref.watch(menuItemsProvider(widget.categoryId));

    return Scaffold(
      backgroundColor: const Color(0xFF1C1813),
      body: restaurantAsync.when(
        data: (restaurant) {
          final isActive = restaurant['is_active'] ?? true;

          if (!isActive) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_busy, size: 80, color: Colors.redAccent),
                  const SizedBox(height: 24),
                  Text(
                    restaurant['name'] ?? 'Restaurant',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'TEMPORARILY CLOSED',
                    style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 32),
                  TextButton.icon(
                    onPressed: () => context.go('/r/${widget.restaurantSlug}'),
                    icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGold),
                    label: const Text('BACK', style: TextStyle(color: AppTheme.primaryGold)),
                  ),
                ],
              ),
            );
          }

          return itemsAsync.when(
            data: (items) {
              final filteredItems = items.where((item) {
                final name = (item['name'] ?? '').toString().toLowerCase();
                final description = (item['description'] ?? '').toString().toLowerCase();
                return name.contains(_searchQuery) || description.contains(_searchQuery);
              }).toList();

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(currentRestaurantProvider(widget.restaurantSlug));
                  ref.invalidate(menuItemsProvider(widget.categoryId));
                  await ref.read(currentRestaurantProvider(widget.restaurantSlug).future);
                  await ref.read(menuItemsProvider(widget.categoryId).future);
                },
                color: AppTheme.primaryGold,
                backgroundColor: const Color(0xFF2B251F),
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: const Color(0xFF1C1813),
                      elevation: 0,
                      toolbarHeight: 80,
                      leadingWidth: 80,
                      leading: Center(
                        child: InkWell(
                          onTap: () => context.go('/r/${widget.restaurantSlug}/categories'),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2B251F),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back, color: AppTheme.primaryGold),
                          ),
                        ),
                      ),
                      title: const Text("Our Menu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                    
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2B251F),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                            decoration: InputDecoration(
                              hintText: 'Search delicious food...',
                              hintStyle: const TextStyle(color: Colors.white38),
                              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGold),
                              suffixIcon: _searchQuery.isNotEmpty 
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.white38),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    if (filteredItems.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 64, color: Colors.white24),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty ? 'No items in this category' : 'No items match "$_searchQuery"',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      )
                    else 
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = filteredItems[index];
                              return _MenuItemCard(item: item, index: index);
                            },
                            childCount: filteredItems.length,
                          ),
                        ),
                      ),
                    
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
            error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
        error: (err, _) => Center(child: Text('Error loading restaurant: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;

  const _MenuItemCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final price = item['price'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B251F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 100,
                height: 100,
                child: CachedNetworkImage(
                  imageUrl: item['image_url'] ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFF1C1813),
                    child: const Icon(Icons.fastfood, color: AppTheme.primaryGold, size: 40),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFF1C1813),
                    child: const Icon(Icons.fastfood, color: AppTheme.primaryGold, size: 40),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    item['description'] ?? '',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "₹ $price",
                    style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1);
  }
}
