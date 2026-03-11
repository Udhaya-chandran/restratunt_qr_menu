import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/rendering.dart';
import '../../../core/theme/app_theme.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1813), // Deep brown/black background
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFF1C1813),
            floating: true,
            toolbarHeight: 80,
            title: Text(
              'Our Menu',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(130),
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B251F),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Find your favorite...',
                          hintStyle: TextStyle(color: Colors.white38),
                          prefixIcon: Icon(Icons.search, color: AppTheme.primaryGold),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        _buildFilterChip('All', isSelected: true),
                        _buildFilterChip('Starters'),
                        _buildFilterChip('Main Course'),
                        _buildFilterChip('Breads'),
                        _buildFilterChip('Desserts'),
                        _buildFilterChip('Drinks'),
                        _buildFilterChip('Combos'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverLayoutBuilder(
              builder: (BuildContext context, SliverConstraints constraints) {
                final double width = constraints.crossAxisExtent;
                // Desktop: 4 cols, Tablet: 3 cols, Mobile: 2 cols
                final int crossAxisCount = width > 1024 ? 4 : width > 600 ? 3 : 2;
                
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: width > 600 ? 0.85 : 0.95, // taller on desktop, squarer on mobile
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final cat = _dummyCategories[index];
                      return _CategoryCard(category: cat, index: index);
                    },
                    childCount: _dummyCategories.length,
                  ),
                );
              },
            ),
          ),
          
          // Bottom padding for the floating bar
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryGold : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryGold),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : AppTheme.primaryGold,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Map<String, String> category;
  final int index;

  const _CategoryCard({required this.category, required this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/menu/${category['id']}'),
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
              // Background Image
              Image.network(
                category['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF221C14), child: const Icon(Icons.fastfood, size: 50, color: Colors.white24)),
              ),
              // Dark Gradient Overlay for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
              // Texts at the bottom
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['name']!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      category['subtitle']!,
                      style: const TextStyle(color: AppTheme.primaryGold, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Item count badge top right
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "${category['count']} ITEMS",
                    style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1),
    );
  }
}

final _dummyCategories = [
  {'id': '1', 'name': 'Starters', 'subtitle': 'Elegant Beginnings', 'count': '12', 'image': 'https://picsum.photos/id/1080/400/500'},
  {'id': '2', 'name': 'Main Course', 'subtitle': "Chef's Signature", 'count': '24', 'image': 'https://picsum.photos/id/292/400/500'},
  {'id': '3', 'name': 'Breads', 'subtitle': 'Oven Fresh', 'count': '8', 'image': 'https://picsum.photos/id/429/400/500'},
  {'id': '4', 'name': 'Desserts', 'subtitle': 'Sweet Indulgence', 'count': '15', 'image': 'https://picsum.photos/id/431/400/500'},
  {'id': '5', 'name': 'Drinks', 'subtitle': 'Fine Spirits', 'count': '32', 'image': 'https://picsum.photos/id/432/400/500'},
  {'id': '6', 'name': 'Combos', 'subtitle': 'Perfect Pairings', 'count': '6', 'image': 'https://picsum.photos/id/433/400/500'},
];
