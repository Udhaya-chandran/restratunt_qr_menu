import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class CustomerLandingScreen extends StatefulWidget {
  const CustomerLandingScreen({super.key});

  @override
  State<CustomerLandingScreen> createState() => _CustomerLandingScreenState();
}

class _CustomerLandingScreenState extends State<CustomerLandingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        context.go('/categories');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titleFontSize = screenWidth > 600 ? 64.0 : 40.0;
    final subtitleFontSize = screenWidth > 600 ? 16.0 : 12.0;

    return Scaffold(
      body: Stack(
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
                    border: Border.all(color: const Color(0xFFEABC3C), width: 3),
                  ),
                  child: const Icon(Icons.restaurant_menu, size: 50, color: Color(0xFFF0A500)),
                ).animate().scale(delay: 200.ms, duration: 800.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 32),
                
                Stack(
                  children: [
                    // Text border effect
                    Text(
                      "L'Essence de L'Or",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: titleFontSize,
                        letterSpacing: 2,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = const Color(0xFFEABC3C).withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Solid text
                    Text(
                      "L'Essence de L'Or",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: titleFontSize,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 16),
                
                Text(
                  "MODERN FRENCH GASTRONOMY",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFEABC3C),
                    letterSpacing: screenWidth > 600 ? 4 : 2,
                    fontSize: subtitleFontSize,
                  ),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => const Icon(Icons.star, color: Color(0xFFEABC3C), size: 20)),
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
