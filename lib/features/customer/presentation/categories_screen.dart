import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/supabase_providers.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  final String restaurantSlug;
  const CategoriesScreen({super.key, required this.restaurantSlug});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
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

    return Scaffold(
      backgroundColor: const Color(0xFF1C1813),
      body: restaurantAsync.when(
        data: (restaurant) {
          final isActive = restaurant['is_active'] ?? true;
          final categoriesAsync = ref.watch(categoriesProvider(restaurant['id']));

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

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(currentRestaurantProvider(widget.restaurantSlug));
              ref.invalidate(categoriesProvider(restaurant['id']));
              await ref.read(currentRestaurantProvider(widget.restaurantSlug).future);
              await ref.read(categoriesProvider(restaurant['id']).future);
            },
            color: AppTheme.primaryGold,
            backgroundColor: const Color(0xFF2B251F),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: const Color(0xFF1C1813),
                  floating: true,
                  toolbarHeight: 80,
                  centerTitle: true,
                  automaticallyImplyLeading: false, // Removed back arrow as requested
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        restaurant['name']?.toUpperCase() ?? 'OUR MENU',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.primaryGold,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                      ),
                      if (restaurant['description'] != null && (restaurant['description'] as String).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            restaurant['description'],
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              letterSpacing: 1.1,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(80),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                            hintText: 'Find your favorite...',
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
                ),
                
                categoriesAsync.when(
                  data: (categories) {
                    final filteredCategories = categories.where((c) {
                      final name = (c['name'] ?? '').toString().toLowerCase();
                      return name.contains(_searchQuery);
                    }).toList();

                    if (filteredCategories.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 64, color: Colors.white24),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty ? 'No categories available' : 'No categories match "$_searchQuery"',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
  
                    return SliverPadding(
                      padding: const EdgeInsets.all(24),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 900 
                            ? 4 
                            : MediaQuery.of(context).size.width > 600 ? 3 : 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final category = filteredCategories[index];
                            return _CategoryCard(
                              category: category, 
                              index: index,
                              restaurantSlug: widget.restaurantSlug,
                            );
                          },
                          childCount: filteredCategories.length,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))),
                  error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red)))),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final int index;
  final String restaurantSlug;

  const _CategoryCard({required this.category, required this.index, required this.restaurantSlug});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/r/$restaurantSlug/menu/${category['id']}'),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: category['image_url'] ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: const Color(0xFF221C14),
                  child: const Center(
                    child: Icon(Icons.fastfood, size: 50, color: AppTheme.primaryGold),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF221C14),
                  child: const Center(
                    child: Icon(Icons.fastfood, size: 50, color: AppTheme.primaryGold),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['name'] ?? 'Untitled',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1),
    );
  }
}
