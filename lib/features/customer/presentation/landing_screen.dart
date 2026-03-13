import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/supabase_providers.dart';

class CustomerLandingScreen extends ConsumerStatefulWidget {
  final String restaurantSlug;
  const CustomerLandingScreen({super.key, required this.restaurantSlug});

  @override
  ConsumerState<CustomerLandingScreen> createState() => _CustomerLandingScreenState();
}

class _CustomerLandingScreenState extends ConsumerState<CustomerLandingScreen> {
  bool _navigationTriggered = false;

  void _setupNavigation(Map<String, dynamic> restaurant) {
    if (_navigationTriggered) return;
    
    if (restaurant['is_active'] == true) {
      _navigationTriggered = true;
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          context.go('/r/${widget.restaurantSlug}/categories');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantAsync = ref.watch(currentRestaurantProvider(widget.restaurantSlug));
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = screenWidth > 600 ? 64.0 : 40.0;
    final subtitleFontSize = screenWidth > 600 ? 16.0 : 12.0;

    return Scaffold(
      body: restaurantAsync.when(
        data: (restaurant) {
          final isActive = restaurant['is_active'] ?? true;
          if (isActive) {
            _setupNavigation(restaurant);
          }
          
          final name = restaurant['name'] ?? "L'Essence de L'Or";
          final tagline = restaurant['description'] ?? "MODERN FRENCH GASTRONOMY";

          return Stack(
            children: [
              // Background Image with dark overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const NetworkImage('https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?auto=format&fit=crop&q=80&w=1200'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.7), BlendMode.darken),
                    ),
                  ),
                ),
              ),
              
              // Central Hero Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.6),
                        border: Border.all(
                          color: isActive ? const Color(0xFFEABC3C) : Colors.redAccent, 
                          width: 3
                        ),
                      ),
                      child: Icon(
                        isActive ? Icons.restaurant_menu : Icons.event_busy, 
                        size: 50, 
                        color: isActive ? const Color(0xFFF0A500) : Colors.redAccent
                      ),
                    ).animate().scale(delay: 200.ms, duration: 800.ms, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 32),
                    
                    Stack(
                      children: [
                        // Text border effect
                        Text(
                          name,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: titleFontSize,
                            letterSpacing: 2,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = (isActive ? const Color(0xFFEABC3C) : Colors.redAccent).withValues(alpha: 0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // Solid text
                        Text(
                          name,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: titleFontSize,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                    
                    if (!isActive) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.redAccent),
                        ),
                        child: Text(
                          'TEMPORARILY CLOSED',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ).animate().fadeIn(delay: 600.ms).shake(),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => ref.invalidate(currentRestaurantProvider(widget.restaurantSlug)),
                        icon: const Icon(Icons.refresh, color: Colors.white70),
                        label: const Text('CHECK AGAIN', style: TextStyle(color: Colors.white70)),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      Text(
                        tagline.toUpperCase(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFFEABC3C),
                          letterSpacing: screenWidth > 600 ? 4 : 2,
                          fontSize: subtitleFontSize,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFEABC3C))),
        error: (err, _) => Center(child: Text('Error loading restaurant: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
