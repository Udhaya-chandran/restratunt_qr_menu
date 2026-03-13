import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

final supabaseServiceProvider = Provider((ref) => SupabaseService());

// Restaurants Provider
final restaurantsProvider = FutureProvider((ref) async {
  return ref.watch(supabaseServiceProvider).getRestaurants();
});

// Single Restaurant Provider
final restaurantDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  final restaurants = await ref.watch(restaurantsProvider.future);
  return restaurants.firstWhere((r) => r['id'] == id);
});

// Categories Provider (Filtered by Restaurant)
final categoriesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, restaurantId) async {
  return ref.watch(supabaseServiceProvider).getCategories(restaurantId);
});

// Menu Items Provider (Filtered by Category)
final menuItemsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, categoryId) async {
  return ref.watch(supabaseServiceProvider).getMenuItems(categoryId);
});

// Current Restaurant Provider (For Customer App via Slug)
final currentRestaurantProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, slug) async {
  return ref.watch(supabaseServiceProvider).getRestaurantBySlug(slug);
});

// Global Categories Provider
final allCategoriesProvider = FutureProvider((ref) async {
  return ref.watch(supabaseServiceProvider).getAllCategories();
});

// Menu Items by Restaurant (For Admin View)
final restaurantMenuItemsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, restaurantId) async {
  return ref.watch(supabaseServiceProvider).getMenuItemsByRestaurant(restaurantId);
});

// Global Menu Items Provider (For Admin View)
final allMenuItemsProvider = FutureProvider((ref) async {
  return ref.watch(supabaseServiceProvider).getAllMenuItems();
});
// Auth Providers
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseServiceProvider).authStateChanges;
});

final userProvider = Provider<User?>((ref) {
  return ref.watch(supabaseServiceProvider).currentUser;
});
