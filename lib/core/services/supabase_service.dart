import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // --- Auth ---
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // --- Restaurants ---
  Future<List<Map<String, dynamic>>> getRestaurants() async {
    // Restaurants still use soft delete (deleted_at) for safety
    return await _client.from('restaurants').select().filter('deleted_at', 'is', null);
  }

  Future<Map<String, dynamic>> getRestaurantBySlug(String slug) async {
    return await _client.from('restaurants').select().eq('slug', slug).single();
  }

  Future<void> saveRestaurant(Map<String, dynamic> restaurant) async {
    await _client.from('restaurants').upsert(restaurant);
  }

  Future<void> updateRestaurantStatus(String id, bool isActive) async {
    await _client.from('restaurants').update({'is_active': isActive}).eq('id', id);
  }

  // --- Categories ---
  Future<List<Map<String, dynamic>>> getCategories(String restaurantId) async {
    return await _client
        .from('categories')
        .select()
        .eq('restaurant_id', restaurantId)
        .order('display_order');
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    return await _client
        .from('categories')
        .select('*, restaurants(name, is_active)')
        .order('created_at', ascending: false);
  }

  Future<void> saveCategory(Map<String, dynamic> category) async {
    await _client.from('categories').upsert(category);
  }

  // --- Menu Items ---
  Future<List<Map<String, dynamic>>> getMenuItems(String categoryId) async {
    return await _client
        .from('menu_items')
        .select()
        .eq('category_id', categoryId)
        .order('display_order');
  }

  Future<List<Map<String, dynamic>>> getMenuItemsByRestaurant(String restaurantId) async {
    return await _client
        .from('menu_items')
        .select('*, categories(name)')
        .eq('restaurant_id', restaurantId);
  }

  Future<List<Map<String, dynamic>>> getAllMenuItems() async {
    return await _client
        .from('menu_items')
        .select('*, restaurants(name, is_active), categories(name)')
        .order('created_at', ascending: false);
  }

  Future<void> saveMenuItem(Map<String, dynamic> item) async {
    await _client.from('menu_items').upsert(item);
  }

  // --- Storage ---
  Future<String> uploadImage(String bucket, String path, File imageFile) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}';
    final fullPath = '${path}/$fileName';
    
    await _client.storage.from(bucket).upload(
      fullPath,
      imageFile,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );

    return _client.storage.from(bucket).getPublicUrl(fullPath);
  }

  // --- Delete ---
  
  /// Soft delete for restaurants
  Future<void> softDeleteRestaurant(String id) async {
    await _client.from('restaurants').update({'deleted_at': DateTime.now().toIso8601String()}).eq('id', id);
  }

  /// Hard delete for categories and menu items
  Future<void> hardDeleteRecord(String table, String id) async {
    await _client.from(table).delete().eq('id', id);
  }
}
