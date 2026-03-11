import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class MenuScreen extends StatelessWidget {
  final String categoryId;
  const MenuScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1813),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1813),
        elevation: 0,
        toolbarHeight: 80,
        leadingWidth: 80,
        leading: Center(
          child: InkWell(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/categories');
              }
            },
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Starters", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text("12 ITEMS AVAILABLE", style: TextStyle(color: AppTheme.primaryGold, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
          ],
        ),

      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Search
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B251F),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search in Starters...',
                        hintStyle: TextStyle(color: Colors.white38),
                        prefixIcon: Icon(Icons.search, color: AppTheme.primaryGold),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(label: 'All', isSelected: true),
                        _FilterChip(label: 'Veg', iconColor: Colors.green),
                        _FilterChip(label: 'Non-Veg', iconColor: Colors.red),
                        _FilterChip(label: 'Bestseller', icon: Icons.local_fire_department),
                        _FilterChip(label: 'Spicy', icon: Icons.whatshot),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _dummyMenuItems[index];
                  return _MenuItemCard(item: item, index: index);
                },
                childCount: _dummyMenuItems.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? iconColor;
  final IconData? icon;

  const _FilterChip({required this.label, this.isSelected = false, this.iconColor, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryGold : const Color(0xFF2B251F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isSelected ? AppTheme.primaryGold : Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconColor != null) ...[
            Container(width: 8, height: 8, decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle)),
            const SizedBox(width: 8),
          ],
          if (icon != null) ...[
            Icon(icon, size: 14, color: isSelected ? Colors.black : AppTheme.primaryGold),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
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
    final bool isBestseller = item['bestseller'] == true;
    final bool isVeg = item['isVeg'] == true;
    final bool isSpicy = item['isSpicy'] == true;

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
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    item['image']!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100, height: 100, color: const Color(0xFF1C1813),
                      child: const Icon(Icons.fastfood, color: Colors.white24),
                    ),
                  ),
                ),
                if (isBestseller)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryGold,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomRight: Radius.circular(8)),
                      ),
                      child: const Text("BESTSELLER", style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      const SizedBox(width: 8),
                      // Veg/Non-veg indicator
                      Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(border: Border.all(color: isVeg ? Colors.green : Colors.red), borderRadius: BorderRadius.circular(2)),
                        child: Center(child: Container(width: 6, height: 6, decoration: BoxDecoration(color: isVeg ? Colors.green : Colors.red, shape: BoxShape.circle))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['description']!,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (isSpicy)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text("SPICY", style: TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  const SizedBox(height: 12),
                  // Price
                  Text(
                    "₹ ${item['price']}",
                    style: const TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 16),
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

final _dummyMenuItems = [
  {
    'name': 'Paneer Tikka',
    'description': 'Creamy marinated paneer cubes grilled to perfection with bell peppers and onions.',
    'price': '249',
    'image': 'https://picsum.photos/id/1080/200/200',
    'bestseller': true,
    'isVeg': true,
    'isSpicy': true,
  },
  {
    'name': 'Chicken Seekh Kebab',
    'description': 'Succulent minced chicken skewers blended with aromatic herbs and char-grilled.',
    'price': '320',
    'image': 'https://picsum.photos/id/292/200/200',
    'bestseller': false,
    'isVeg': false,
    'isSpicy': false,
  },
  {
    'name': 'Veg Spring Rolls',
    'description': 'Crispy fried rolls stuffed with seasoned julienned vegetables and glass noodles.',
    'price': '180',
    'image': 'https://picsum.photos/id/429/200/200',
    'bestseller': false,
    'isVeg': true,
    'isSpicy': false,
  },
  {
    'name': 'Classic Samosa (2pcs)',
    'description': 'Flaky pastry stuffed with spiced potatoes and green peas. Served with mint chutney.',
    'price': '99',
    'image': 'https://picsum.photos/id/431/200/200',
    'bestseller': true,
    'isVeg': true,
    'isSpicy': false,
  },
  {
    'name': 'Drums of Heaven',
    'description': 'Crispy chicken wings tossed in a spicy and tangy schezwan sauce.',
    'price': '285',
    'image': 'https://picsum.photos/id/432/200/200',
    'bestseller': false,
    'isVeg': false,
    'isSpicy': true,
  },
];
