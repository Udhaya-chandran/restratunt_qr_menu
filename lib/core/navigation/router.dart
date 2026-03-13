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
import '../../features/customer/presentation/web_home_screen.dart';
import '../../features/admin/presentation/menu_item_list_screen.dart';
import '../../features/admin/presentation/menu_item_form_screen.dart';
import '../../features/admin/qr_generator/qr_generator_screen.dart';
import '../../features/admin/presentation/restaurant_details_screen.dart';
import '../../../core/providers/supabase_providers.dart';

// Customer Web App Router
final customerRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WebHomeScreen(),
      ),
      GoRoute(
        path: '/r/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug']!;
          return CustomerLandingScreen(restaurantSlug: slug);
        },
        routes: [
          GoRoute(
            path: 'categories',
            builder: (context, state) {
              final slug = state.pathParameters['slug']!;
              return CategoriesScreen(restaurantSlug: slug);
            },
          ),
          GoRoute(
            path: 'menu/:categoryId',
            builder: (context, state) {
              final slug = state.pathParameters['slug']!;
              final categoryId = state.pathParameters['categoryId']!;
              return MenuScreen(restaurantSlug: slug, categoryId: categoryId);
            },
          ),
        ],
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
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const RestaurantFormScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return RestaurantDetailsScreen(restaurantId: id);
            },
          ),
          GoRoute(
            path: 'edit/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return FutureBuilder<Map<String, dynamic>>(
                future: ref.read(supabaseServiceProvider).getRestaurants().then((list) => list.firstWhere((r) => r['id'] == id)),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return RestaurantFormScreen(restaurant: snapshot.data);
                  }
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                },
              );
            },
          ),
        ],
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
        path: '/admin-categories/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FutureBuilder<Map<String, dynamic>>(
            future: ref.read(supabaseServiceProvider).getAllCategories().then((list) => list.firstWhere((c) => c['id'] == id)),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return CategoryFormScreen(category: snapshot.data);
              }
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            },
          );
        },
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
        path: '/admin-menu/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FutureBuilder<Map<String, dynamic>>(
            future: ref.read(supabaseServiceProvider).getAllMenuItems().then((list) => list.firstWhere((i) => i['id'] == id)),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return MenuItemFormScreen(item: snapshot.data);
              }
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            },
          );
        },
      ),
      GoRoute(
        path: '/qr-generator',
        builder: (context, state) {
          final slug = state.uri.queryParameters['slug'];
          final name = state.uri.queryParameters['name'];
          return QrGeneratorScreen(restaurantSlug: slug, restaurantName: name);
        },
      ),
    ],
  );
});
