import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/router.dart';
import 'core/theme/app_theme.dart';

class RestaurantManagementApp extends ConsumerWidget {
  const RestaurantManagementApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = kIsWeb ? ref.watch(customerRouterProvider) : ref.watch(adminRouterProvider);

    return MaterialApp.router(
      title: 'Luxury Restaurant',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
