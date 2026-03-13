import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';

class QrGeneratorScreen extends StatelessWidget {
  final String? restaurantSlug;
  final String? restaurantName;

  const QrGeneratorScreen({
    super.key, 
    this.restaurantSlug,
    this.restaurantName,
  });

  Future<void> _launchURL(BuildContext context, String url) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Open Link', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to open the menu in your browser?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('OPEN', style: TextStyle(color: AppTheme.primaryGold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch URL')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displaySlug = restaurantSlug ?? 'default';
    final displayName = restaurantName ?? 'Restaurant';
    // Live hosted URL on Netlify
    final qrData = 'https://guileless-kelpie-bf69e2.netlify.app/r/$displaySlug';

    return Scaffold(
      appBar: AppBar(
        title: const Text('GENERATE QR CODE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryGold,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                "Scan to view menu",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 48),
              
              InkWell(
                onTap: () => _launchURL(context, qrData),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGold.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 250.0,
                    backgroundColor: Colors.white,
                  ),
                ),
              ).animate().scale(delay: 400.ms, duration: 600.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 12),
              Text(
                "Click to open",
                style: TextStyle(
                  color: AppTheme.primaryGold.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(delay: 500.ms),
              
              const SizedBox(height: 48),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ActionButton(
                    icon: Icons.download,
                    label: 'DOWNLOAD',
                    color: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(
                          const SnackBar(content: Text('Downloading QR Code...')),
                        );
                    },
                  ),
                  const SizedBox(width: 16),
                  _ActionButton(
                    icon: Icons.print,
                    label: 'PRINT',
                    color: AppTheme.primaryGold,
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                        ..clearSnackBars()
                        ..showSnackBar(
                          const SnackBar(content: Text('Sending to Printer...')),
                        );
                    },
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.black),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
    );
  }
}
