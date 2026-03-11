import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/customer/presentation/landing_screen.dart';
import '../../features/customer/presentation/categories_screen.dart';
import '../../features/customer/presentation/menu_screen.dart';
import '../../features/admin/presentation/splash_screen.dart';
import '../../features/admin/presentation/sign_in_screen.dart';
import '../../features/admin/presentation/dashboard_screen.dart';
import '../../features/admin/presentation/restaurant_list_screen.dart';
import '../../features/admin/presentation/restaurant_form_screen.dart';
import '../../features/admin/presentation/category_list_screen.dart';
import '../../features/admin/presentation/category_form_screen.dart';
import '../../features/admin/presentation/menu_item_list_screen.dart';
import '../../features/admin/presentation/menu_item_form_screen.dart';
import '../../features/admin/qr_generator/qr_generator_screen.dart';

// Customer Web App Router
final customerRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const CustomerLandingScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/menu/:categoryId',
        builder: (context, state) {
          final id = state.pathParameters['categoryId'] ?? '1';
          return MenuScreen(categoryId: id);
        },
      ),
    ],
  );
});

// Admin Mobile App Router
final adminRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AdminSplashScreen(),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) => const AdminSignInScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/restaurants',
        builder: (context, state) => const RestaurantListScreen(),
      ),
      GoRoute(
        path: '/restaurants/add',
        builder: (context, state) => const RestaurantFormScreen(),
      ),
      GoRoute(
        path: '/admin-categories',
        builder: (context, state) => const CategoryListScreen(),
      ),
      GoRoute(
        path: '/admin-categories/add',
        builder: (context, state) => const CategoryFormScreen(),
      ),
      GoRoute(
        path: '/admin-menu',
        builder: (context, state) => const MenuItemListScreen(),
      ),
      GoRoute(
        path: '/admin-menu/add',
        builder: (context, state) => const MenuItemFormScreen(),
      ),
      GoRoute(
        path: '/qr-generator',
        builder: (context, state) => const QrGeneratorScreen(),
      ),
    ],
  );
});
